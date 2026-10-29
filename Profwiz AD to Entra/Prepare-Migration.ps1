#   Prepare-Migration.ps1
#   Prep phase for a ProfWiz domain-to-Entra migration. Sets up Edge enterprise
#   sync and OneDrive Known Folder Move so user data is already syncing before
#   you cut over. Give it a few days to soak.
#
#   MSP Automator Labs LLC (c) 2026 - Ceej the MSP Automator
#   MIT License. Provided as-is, no warranty. Pilot it before you deploy it.
#
#   Quick start (run elevated, or as SYSTEM from Intune / ConfigMgr / GPO):
#     .\Prepare-Migration.ps1 -TenantId <tenant-guid> -WhatIf          # dry run
#     .\Prepare-Migration.ps1 -TenantId <tenant-guid> -CloseBrowsers   # do it
#     .\Prepare-Migration.ps1 -Revert                                  # undo it
#   Full help: Get-Help .\Prepare-Migration.ps1 -Full

<#
.SYNOPSIS
    Prep phase for a ProfWiz domain-to-Entra migration. Run it well before cutover.

.DESCRIPTION
    Sets up the stuff that needs time to sync before cutover, so each user's data is
    already in the cloud by the time ProfWiz runs. This script doesn't copy or move any
    user data. That's the cutover script's job (Invoke-MigrationCutover.ps1). All this
    one does is set policy and reset some browser state:

      1. Edge enterprise sync. Forces sign-in with the work account and syncs favorites,
         passwords, history, settings and the rest to the cloud under the Entra account.
         That's how browser data survives the identity change, because it gets
         re-encrypted under the new account instead of the old one.
      2. Edge first-run import. Brings the first-run experience back so Edge imports from
         Chrome or Firefox the next time it launches.
      3. OneDrive Known Folder Move. Redirects Desktop, Documents and Pictures into
         OneDrive so they come along without any copying. Needs -TenantId.
      4. Chrome report. Lists which users have Chrome saved passwords, because those
         users might need a one-time manual step (see .NOTES).

    Run it elevated: as SYSTEM from Intune, ConfigMgr or a GPO startup script, or from an
    admin shell. Edge and OneDrive pick up policy on their next start or policy refresh,
    so it's fine to run this while users are logged on.

    The first run exports every policy key it's about to change into -StateDir.
    -Revert puts them back.

.PARAMETER TenantId
    Your Entra tenant ID (a GUID). Needed for OneDrive Known Folder Move. Leave it off
    and the script only does the Edge side, and it'll warn you that it skipped KFM.

.PARAMETER ImportFrom
    Which browser Edge imports from at first run. Auto (the default) picks Chrome if any
    local profile has Chrome data, then Firefox, then whatever the default browser is.
    None skips the import but still brings the first-run experience back.

.PARAMETER SignIn
    Force (the default) makes users sign in to Edge before they can browse, so the
    profile is tied to an account that can actually sync. Allow makes sign-in optional.

.PARAMETER SignInPattern
    Optional regex for which accounts can sign in to Edge, like '.*@contoso\.com'.
    Stops users from signing in with their personal Microsoft account. Test this with
    anyone who already has a personal account in an Edge profile, because they will
    absolutely call you about it.

.PARAMETER CloseBrowsers
    Closes Edge, Chrome and Firefox so the new policy and the import happen on the next
    launch. Edge's startup boost keeps msedge.exe running in the background, so without
    this the changes might not land until the user signs in again.

.PARAMETER Revert
    Restores every policy key that was backed up on the first run, then exits.

.PARAMETER StateDir
    Where the log, the policy backups and the password handoff folder go.
    Default: C:\ProgramData\EntraMigrationPrep

.EXAMPLE
    .\Prepare-Migration.ps1 -TenantId 00000000-0000-0000-0000-000000000000 -WhatIf

.EXAMPLE
    .\Prepare-Migration.ps1 -TenantId <guid> -CloseBrowsers -SignInPattern '.*@contoso\.com'

.EXAMPLE
    .\Prepare-Migration.ps1 -Revert

.NOTES
    Why Chrome passwords get their own step:
      Chrome protects saved passwords with App-Bound Encryption. The key is tied to Chrome's
      own application identity and sealed by a SYSTEM service, so Chrome running as the user
      is the ONLY thing that can decrypt them. Edge can't. Nothing you run as the user or as
      admin can. Copying the Chrome profile folder doesn't help because the key doesn't come
      with it. Those tools floating around that claim to "decrypt v20" are credential
      harvesters. Do not run them on client machines.

      What actually works, in order:
        A. Let Edge import from Chrome (that's the AutoImportAtFirstRun policy this script
           sets) and check in your pilot that the passwords really show up in Edge. Log into
           a real site to test it. If they made it, Edge sync carries them and you're done,
           with no plaintext anywhere.
        B. If they didn't make it, the USER has to export them from Chrome
           (chrome://password-manager/settings, then Export). Chrome makes them
           re-authenticate first, and there's no scripting around that. It's on purpose: the
           person who owns the passwords has to approve moving them. Save the CSV into the
           PasswordHandoff folder this script creates (it's outside OneDrive so it never
           syncs), import it into Edge (Settings > Passwords > Import > Passwords CSV file),
           let Edge sync it, and the cutover script shreds the folder. Keep that CSV off
           Desktop, Documents and Pictures, or KFM will upload it to the cloud for you.

      Don't set Chrome's ApplicationBoundEncryptionEnabled to 0 to get around this. It weakens
      security, and it isn't retroactive, so the passwords already saved stay encrypted anyway.
#>
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$TenantId,

    [ValidateSet('Auto', 'Chrome', 'Firefox', 'DefaultBrowser', 'None')]
    [string]$ImportFrom = 'Auto',

    [ValidateSet('Force', 'Allow')]
    [string]$SignIn = 'Force',

    [string]$SignInPattern,

    [switch]$CloseBrowsers,

    [switch]$Revert,

    [string]$StateDir = (Join-Path $env:ProgramData 'EntraMigrationPrep')
)

# Intune and ConfigMgr sometimes launch scripts in 32-bit PowerShell. If that happens,
# relaunch in 64-bit and pass the same parameters through.
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $ps64 = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path $ps64) {
        $relaunchArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
        foreach ($param in $PSBoundParameters.GetEnumerator()) {
            if ($param.Value -is [System.Management.Automation.SwitchParameter]) {
                if ($param.Value.IsPresent) { $relaunchArgs += "-$($param.Key)" }
            }
            else {
                $relaunchArgs += "-$($param.Key)"
                $relaunchArgs += [string]$param.Value
            }
        }
        & $ps64 @relaunchArgs
        exit $LASTEXITCODE
    }
}

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'This needs to run elevated (admin or SYSTEM).'
}

if ($TenantId -and $TenantId -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') {
    throw "TenantId '$TenantId' isn't a GUID. Grab the real one from Entra admin center > Overview > Tenant ID."
}

# The policy keys this script changes. Each one gets exported before the first change so
# -Revert has something to restore.
$EdgeKey   = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
$OneDrive  = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'
$ManagedKeys = @(
    @{ Ps = $EdgeKey;  Reg = 'HKLM\SOFTWARE\Policies\Microsoft\Edge';     Backup = 'Edge.before.reg' }
    @{ Ps = $OneDrive; Reg = 'HKLM\SOFTWARE\Policies\Microsoft\OneDrive'; Backup = 'OneDrive.before.reg' }
)

New-Item -ItemType Directory -Path $StateDir -Force -WhatIf:$false | Out-Null
$HandoffDir = Join-Path $StateDir 'PasswordHandoff'
$LogFile = Join-Path $StateDir ('Prepare_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))

#region Helpers

function Write-MigLog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '{0:yyyy-MM-dd HH:mm:ss} [{1}] {2}' -f (Get-Date), $Level, $Message
    Add-Content -LiteralPath $LogFile -Value $line -WhatIf:$false
    switch ($Level) {
        'WARN'  { Write-Warning $Message }
        'ERROR' { Write-Host $line -ForegroundColor Red }
        default { Write-Host $line }
    }
}

function Invoke-Reg {
    param([Parameter(Mandatory)][string]$Arguments)
    # Going through Start-Process instead of calling reg.exe directly, because Windows
    # PowerShell 5.1 turns anything a native exe writes to stderr into a terminating error
    # when $ErrorActionPreference is Stop.
    $regExe = Join-Path $env:WINDIR 'System32\reg.exe'
    $proc = Start-Process -FilePath $regExe -ArgumentList $Arguments -Wait -PassThru -WindowStyle Hidden
    if ($proc.ExitCode -ne 0) { throw "reg.exe $Arguments failed with exit code $($proc.ExitCode)" }
}

function Get-Policy {
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)][string]$Name)
    $item = Get-ItemProperty -Path $Key -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $item) { return $item.$Name }
    return $null
}

function Set-Policy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Name,
        $Value,
        [ValidateSet('DWord', 'String')][string]$Type = 'DWord'
    )
    $current = Get-Policy -Key $Key -Name $Name
    $was = if ($null -eq $current) { 'not set' } else { $current }
    if ($PSCmdlet.ShouldProcess("$Key\$Name", "Set to $Value (was $was)")) {
        if (-not (Test-Path $Key)) { New-Item -Path $Key -Force | Out-Null }
        New-ItemProperty -Path $Key -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-MigLog "Set $Name = $Value (was $was)"
    }
}

function Set-ListPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string[]]$Values
    )
    $listKey = Join-Path $Key $Name
    if ($PSCmdlet.ShouldProcess("$listKey", "Set list to $($Values -join ', ')")) {
        if (Test-Path $listKey) { Remove-Item -Path $listKey -Recurse -Force }
        New-Item -Path $listKey -Force | Out-Null
        for ($i = 0; $i -lt $Values.Count; $i++) {
            New-ItemProperty -Path $listKey -Name ([string]($i + 1)) -Value $Values[$i] -PropertyType String -Force | Out-Null
        }
        Write-MigLog "Set $Name = $($Values -join ', ')"
    }
}

function Remove-Policy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Reason
    )
    $current = Get-Policy -Key $Key -Name $Name
    if ($null -eq $current) { return }
    if ($PSCmdlet.ShouldProcess("$Key\$Name", "Remove (currently $current)")) {
        Remove-ItemProperty -Path $Key -Name $Name -Force
        Write-MigLog "Removed $Name (was $current) because $Reason" 'WARN'
    }
}

function Remove-ListPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Reason
    )
    $listKey = Join-Path $Key $Name
    if (-not (Test-Path $listKey)) { return }
    if ($PSCmdlet.ShouldProcess("$listKey", 'Remove list policy')) {
        Remove-Item -Path $listKey -Recurse -Force
        Write-MigLog "Removed list policy $Name because $Reason" 'WARN'
    }
}

function Get-JoinState {
    $state = [ordered]@{ AzureAdJoined = $false; DomainJoined = $false }
    try {
        $out = & (Join-Path $env:WINDIR 'System32\dsregcmd.exe') /status
        $state.AzureAdJoined = [bool]($out -match '^\s*AzureAdJoined\s*:\s*YES')
        $state.DomainJoined  = [bool]($out -match '^\s*DomainJoined\s*:\s*YES')
    }
    catch {
        Write-MigLog "Could not read join state from dsregcmd: $($_.Exception.Message)" 'WARN'
    }
    [pscustomobject]$state
}

function Get-UserProfilePath {
    Get-CimInstance -ClassName Win32_UserProfile |
        Where-Object { -not $_.Special -and $_.LocalPath -and (Test-Path -LiteralPath $_.LocalPath) } |
        Select-Object -ExpandProperty LocalPath
}

#endregion

try {
    Write-MigLog ('=== Migration PREP started. TenantId={0} ImportFrom={1} SignIn={2} CloseBrowsers={3} Revert={4} WhatIf={5} ===' -f
        ($(if ($TenantId) { 'set' } else { 'none' })), $ImportFrom, $SignIn, $CloseBrowsers.IsPresent, $Revert.IsPresent, [bool]$WhatIfPreference)

    #region Revert
    if ($Revert) {
        $any = $false
        foreach ($k in $ManagedKeys) {
            $backup = Join-Path $StateDir $k.Backup
            $none   = Join-Path $StateDir ($k.Backup -replace '\.reg$', '.none')
            if (Test-Path -LiteralPath $backup) {
                $any = $true
                if ($PSCmdlet.ShouldProcess($k.Reg, "Restore from $($k.Backup)")) {
                    if (Test-Path $k.Ps) { Remove-Item -Path $k.Ps -Recurse -Force }
                    Invoke-Reg "import `"$backup`""
                    Remove-Item -LiteralPath $backup -Force
                    Write-MigLog "Restored $($k.Reg) from backup."
                }
            }
            elseif (Test-Path -LiteralPath $none) {
                $any = $true
                if ($PSCmdlet.ShouldProcess($k.Reg, 'Remove (did not exist before this script ran)')) {
                    if (Test-Path $k.Ps) { Remove-Item -Path $k.Ps -Recurse -Force }
                    Remove-Item -LiteralPath $none -Force
                    Write-MigLog "Removed $($k.Reg) since it didn't exist before the first run."
                }
            }
        }
        if (-not $any) { Write-MigLog "No backups found in $StateDir; nothing to revert." 'WARN'; exit 1 }
        exit 0
    }
    #endregion

    #region Back up managed policy keys (first run only)
    if (-not $WhatIfPreference) {
        foreach ($k in $ManagedKeys) {
            $backup = Join-Path $StateDir $k.Backup
            $none   = Join-Path $StateDir ($k.Backup -replace '\.reg$', '.none')
            if ((Test-Path -LiteralPath $backup) -or (Test-Path -LiteralPath $none)) { continue }
            if (Test-Path $k.Ps) {
                Invoke-Reg "export `"$($k.Reg)`" `"$backup`" /y"
                Write-MigLog "Backed up $($k.Reg) to $backup"
            }
            else {
                New-Item -ItemType File -Path $none -Force | Out-Null
                Write-MigLog "$($k.Reg) did not exist before this run (recorded for -Revert)."
            }
        }
    }
    #endregion

    #region Inventory
    $join = Get-JoinState
    Write-MigLog ('Join state: Entra/hybrid joined = {0}, domain joined = {1}' -f $join.AzureAdJoined, $join.DomainJoined)
    if (-not $join.AzureAdJoined -and $SignIn -eq 'Allow') {
        Write-MigLog 'Device isn''t Entra or hybrid joined and sign-in is optional. Nothing syncs unless users sign in to Edge with their work account themselves.' 'WARN'
    }

    $inventory = @(foreach ($path in Get-UserProfilePath) {
        [pscustomobject]@{
            Profile       = $path
            HasEdge       = Test-Path -LiteralPath (Join-Path $path 'AppData\Local\Microsoft\Edge\User Data')
            Chrome        = Test-Path -LiteralPath (Join-Path $path 'AppData\Local\Google\Chrome\User Data\Local State')
            ChromeLogins  = Test-Path -LiteralPath (Join-Path $path 'AppData\Local\Google\Chrome\User Data\Default\Login Data')
            Firefox       = Test-Path -LiteralPath (Join-Path $path 'AppData\Roaming\Mozilla\Firefox\profiles.ini')
        }
    })
    foreach ($u in $inventory) {
        Write-MigLog ('Profile {0} - Edge:{1} Chrome:{2} ChromeLogins:{3} Firefox:{4}' -f $u.Profile, $u.HasEdge, $u.Chrome, $u.ChromeLogins, $u.Firefox)
    }

    $source = $ImportFrom
    if ($source -eq 'Auto') {
        if (@($inventory | Where-Object Chrome).Count -gt 0) { $source = 'Chrome' }
        elseif (@($inventory | Where-Object Firefox).Count -gt 0) { $source = 'Firefox' }
        else { $source = 'DefaultBrowser' }
        Write-MigLog "Auto-selected import source: $source"
    }
    # AutoImportAtFirstRun: 0 = default browser, 2 = Chrome, 4 = no import, 5 = Firefox
    $importValue = @{ DefaultBrowser = 0; Chrome = 2; None = 4; Firefox = 5 }[$source]
    $manualImport = @(switch ($source) {
        'Chrome'  { $inventory | Where-Object Firefox | ForEach-Object { '{0} (Firefox)' -f $_.Profile } }
        'Firefox' { $inventory | Where-Object Chrome  | ForEach-Object { '{0} (Chrome)' -f $_.Profile } }
    })
    foreach ($m in $manualImport) {
        Write-MigLog "Edge only auto-imports from one browser. Import this one by hand at edge://settings/profiles/importBrowsingData: $m" 'WARN'
    }
    #endregion

    #region Close browsers
    if ($CloseBrowsers) {
        foreach ($name in 'msedge', 'chrome', 'firefox') {
            $procs = @(Get-Process -Name $name -ErrorAction SilentlyContinue)
            if ($procs.Count -gt 0 -and $PSCmdlet.ShouldProcess("$name.exe ($($procs.Count) processes)", 'Stop')) {
                $procs | Stop-Process -Force -ErrorAction SilentlyContinue
                Write-MigLog "Closed $name.exe ($($procs.Count) processes)"
            }
        }
    }
    else {
        $running = @('msedge', 'chrome', 'firefox' | Where-Object { Get-Process -Name $_ -ErrorAction SilentlyContinue })
        if ($running.Count -gt 0) {
            Write-MigLog ('Still running: {0}. Edge picks up the new policy on its next start, and the import needs the source browser closed. Re-run with -CloseBrowsers to close them now.' -f ($running -join ', ')) 'WARN'
        }
    }
    #endregion

    #region Edge: first-run import
    Set-Policy -Key $EdgeKey -Name HideFirstRunExperience -Value 0
    Set-Policy -Key $EdgeKey -Name AutoImportAtFirstRun -Value $importValue
    if ($source -ne 'None') {
        foreach ($name in 'ImportFavorites', 'ImportSavedPasswords', 'ImportHistory', 'ImportAutofillFormData') {
            Set-Policy -Key $EdgeKey -Name $name -Value 1
        }
    }
    #endregion

    #region Edge: sign-in and enterprise sync
    Set-Policy -Key $EdgeKey -Name BrowserSignin -Value ($(if ($SignIn -eq 'Force') { 2 } else { 1 }))  # 1 allowed, 2 forced
    if ($SignInPattern) { Set-Policy -Key $EdgeKey -Name RestrictSigninToPattern -Value $SignInPattern -Type String }
    Set-Policy -Key $EdgeKey -Name SyncDisabled -Value 0
    Set-Policy -Key $EdgeKey -Name ForceSync -Value 1
    Set-ListPolicy -Key $EdgeKey -Name ForceSyncTypes -Values @(
        'favorites', 'passwords', 'history', 'settings', 'addressesAndMore', 'openTabs', 'collections', 'extensions'
    )
    Set-Policy -Key $EdgeKey -Name PasswordManagerEnabled -Value 1
    Set-Policy -Key $EdgeKey -Name SavingBrowserHistoryDisabled -Value 0
    Remove-ListPolicy -Key $EdgeKey -Name SyncTypesListDisabled -Reason 'it excludes data types from sync'
    Remove-Policy -Key $EdgeKey -Name ConfigureOnPremisesAccountAutoSignIn -Reason 'it signs Edge in with the AD account, which cannot use cloud sync'
    Remove-Policy -Key $EdgeKey -Name OnlyOnPremisesImplicitSigninEnabled -Reason 'it blocks implicit sign-in with the Entra account'
    if ((Get-Policy -Key $EdgeKey -Name ImplicitSignInEnabled) -eq 0) {
        Remove-Policy -Key $EdgeKey -Name ImplicitSignInEnabled -Reason 'it blocks implicit sign-in with the Entra account'
    }
    if ((Get-Policy -Key $EdgeKey -Name AllowDeletingBrowserHistory) -eq 0) {
        Write-MigLog 'AllowDeletingBrowserHistory is disabled, which also kills history sync. Leaving it alone. Enable it if users need their history to come over.' 'WARN'
    }
    #endregion

    #region OneDrive Known Folder Move
    if ($TenantId) {
        Set-Policy -Key $OneDrive -Name SilentAccountConfig -Value 1
        Set-Policy -Key $OneDrive -Name KFMSilentOptIn -Value $TenantId -Type String
        Set-Policy -Key $OneDrive -Name KFMSilentOptInWithNotification -Value 1
        Set-Policy -Key $OneDrive -Name KFMBlockOptOut -Value 1
        Set-Policy -Key $OneDrive -Name FilesOnDemandEnabled -Value 1
        Write-MigLog 'OneDrive KFM configured: Desktop, Documents and Pictures will move into OneDrive as each user signs in.'
    }
    else {
        Write-MigLog 'No -TenantId, so OneDrive Known Folder Move was NOT configured. Desktop, Documents and Pictures won''t move until it is. Re-run with -TenantId <guid>.' 'WARN'
    }
    #endregion

    #region Edge first-run reset for existing users
    $resetCount = 0
    foreach ($u in $inventory) {
        $sentinel = Join-Path $u.Profile 'AppData\Local\Microsoft\Edge\User Data\First Run'
        if (Test-Path -LiteralPath $sentinel) {
            if ($PSCmdlet.ShouldProcess($sentinel, 'Delete Edge first-run marker')) {
                Remove-Item -LiteralPath $sentinel -Force
                $resetCount++
                Write-MigLog "Reset Edge first run for $($u.Profile)"
            }
        }
    }
    #endregion

    #region Chrome password handoff
    $chromePwUsers = @($inventory | Where-Object ChromeLogins | Select-Object -ExpandProperty Profile)
    if ($chromePwUsers.Count -gt 0) {
        if (-not (Test-Path -LiteralPath $HandoffDir) -and $PSCmdlet.ShouldProcess($HandoffDir, 'Create password-handoff folder (outside OneDrive)')) {
            New-Item -ItemType Directory -Path $HandoffDir -Force | Out-Null
        }
        Write-MigLog ("{0} user(s) have Chrome saved passwords. Check in your pilot that Edge's import actually brings them over. If it doesn't, each user needs to export from chrome://password-manager/settings into '$HandoffDir', import into Edge, and let it sync. Cutover shreds that folder. Details are in this script's .NOTES." -f $chromePwUsers.Count) 'WARN'
        foreach ($p in $chromePwUsers) { Write-MigLog "  Chrome passwords present: $p" }
    }
    #endregion

    Write-MigLog ('PREP done. Import source: {0}. First run reset for {1} profile(s). KFM: {2}. Chrome-password users: {3}. Run Invoke-MigrationCutover.ps1 at cutover.' -f
        $source, $resetCount, ($(if ($TenantId) { 'configured' } else { 'skipped' })), $chromePwUsers.Count)

    [pscustomobject]@{
        ImportSource        = $source
        SignIn              = $SignIn
        EntraOrHybridJoined = $join.AzureAdJoined
        KfmConfigured       = [bool]$TenantId
        FirstRunReset       = $resetCount
        ManualImportNeeded  = $manualImport
        ChromePasswordUsers = $chromePwUsers
        HandoffDir          = $HandoffDir
        LogFile             = $LogFile
    }
}
catch {
    Write-MigLog "Failed: $($_.Exception.Message)" 'ERROR'
    exit 1
}
