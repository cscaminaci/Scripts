#   Invoke-MigrationCutover.ps1
#   Cutover phase for a ProfWiz domain-to-Entra migration. Copies the AppData
#   leftovers into OneDrive, checks every user is ready, and shreds the
#   password handoff folder. Run it inside the ProfWiz sequence right before
#   the account switch.
#
#   MSP Automator Labs LLC (c) 2026 - Ceej the MSP Automator
#   MIT License. Provided as-is, no warranty. Pilot it before you deploy it.
#
#   Quick start (run elevated, or as SYSTEM inside the ProfWiz task sequence):
#     .\Invoke-MigrationCutover.ps1 -WhatIf     # dry run
#     .\Invoke-MigrationCutover.ps1             # stage and check (non-zero exit = hold)
#     .\Invoke-MigrationCutover.ps1 -Force      # go even if someone isn't ready
#   Full help: Get-Help .\Invoke-MigrationCutover.ps1 -Full

<#
.SYNOPSIS
    Cutover phase for a ProfWiz domain-to-Entra migration. Run it inside the ProfWiz
    sequence, right before the account switch.

.DESCRIPTION
    Grabs the last of the data and checks whether each user is actually safe to cut over.
    This assumes Prepare-Migration.ps1 already ran and everything has had time to sync.
    Here's what it does:

      1. Copies the AppData leftovers that Known Folder Move doesn't carry (Sticky Notes,
         Outlook signatures, Office templates and custom dictionary, Teams backgrounds)
         into <OneDrive>\_MigrationBackup, using the same path relative to the profile so
         it's obvious where everything goes back. It only copies. The originals stay put.
      2. Checks each user: is Edge signed in to an account, and is OneDrive set up? Each
         one gets logged as READY or NOT READY.
      3. Shreds the PasswordHandoff folder from the prep step so no exported password CSV
         makes it past cutover.

    The exit code is 0 only when every user with an Edge profile is READY (or you pass
    -Force), so ProfWiz can hold the account switch based on it.

    Run it elevated, as SYSTEM or an admin, inside the ProfWiz task sequence.

.PARAMETER StateDir
    Has to match whatever the prep run used. Default: C:\ProgramData\EntraMigrationPrep

.PARAMETER SkipStaging
    Skip copying the leftovers. Only does the readiness check and the shred.

.PARAMETER Force
    Exit 0 even if some users are NOT READY. Only use this if you're gating cutover some
    other way. Without it, one NOT READY user makes the script exit non-zero so ProfWiz
    stops before it cuts anyone over half done.

.EXAMPLE
    .\Invoke-MigrationCutover.ps1 -WhatIf

.EXAMPLE
    .\Invoke-MigrationCutover.ps1
    # exit 0 means everyone is ready. Non-zero means at least one user isn't.
#>
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$StateDir = (Join-Path $env:ProgramData 'EntraMigrationPrep'),
    [switch]$SkipStaging,
    [switch]$Force
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
                $relaunchArgs += "-$($param.Key)"; $relaunchArgs += [string]$param.Value
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

New-Item -ItemType Directory -Path $StateDir -Force -WhatIf:$false | Out-Null
$HandoffDir = Join-Path $StateDir 'PasswordHandoff'
$LogFile = Join-Path $StateDir ('Cutover_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))

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

function Get-UserProfilePath {
    Get-CimInstance -ClassName Win32_UserProfile |
        Where-Object { -not $_.Special -and $_.LocalPath -and (Test-Path -LiteralPath $_.LocalPath) } |
        Select-Object -ExpandProperty LocalPath
}

function Get-OneDrivePath {
    # Running as SYSTEM we can't see the user's $env:OneDrive or HKCU, so go find the folder
    # on disk. If there's a business 'OneDrive - <Org>' folder, use it over a personal 'OneDrive'.
    param([Parameter(Mandatory)][string]$ProfilePath)
    $candidates = @(Get-ChildItem -LiteralPath $ProfilePath -Directory -Filter 'OneDrive*' -ErrorAction SilentlyContinue)
    if ($candidates.Count -eq 0) { return $null }
    $business = $candidates | Where-Object { $_.Name -like 'OneDrive - *' } | Select-Object -First 1
    if ($business) { return $business.FullName }
    return ($candidates | Select-Object -First 1).FullName
}

function Get-MigrationLeftover {
    # AppData stuff Known Folder Move doesn't carry, so we copy it into OneDrive ourselves.
    # Paths are relative to the profile root. Add a line every time a user finds something
    # else missing after cutover.
    @(
        [pscustomobject]@{ Label = 'Sticky Notes';            RelativePath = 'AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState' }
        [pscustomobject]@{ Label = 'Outlook signatures';      RelativePath = 'AppData\Roaming\Microsoft\Signatures' }
        [pscustomobject]@{ Label = 'Office custom templates'; RelativePath = 'AppData\Roaming\Microsoft\Templates' }
        [pscustomobject]@{ Label = 'Office custom dictionary';RelativePath = 'AppData\Roaming\Microsoft\UProof' }
        [pscustomobject]@{ Label = 'Teams backgrounds (classic)'; RelativePath = 'AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads' }
        [pscustomobject]@{ Label = 'Teams backgrounds (new)';     RelativePath = 'AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads' }
    )
}

function Test-EdgeReady {
    # Returns $true if any Edge profile is signed in, meaning its User Data\<profile>\Preferences
    # JSON has an account_info entry with an email in it. It's a quick local check. It can't
    # tell you whether the cloud upload actually finished.
    param([Parameter(Mandatory)][string]$ProfilePath)
    $userData = Join-Path $ProfilePath 'AppData\Local\Microsoft\Edge\User Data'
    if (-not (Test-Path -LiteralPath $userData)) { return $false }
    $prefFiles = @(Get-ChildItem -LiteralPath $userData -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile *' } |
        ForEach-Object { Join-Path $_.FullName 'Preferences' } |
        Where-Object { Test-Path -LiteralPath $_ })
    foreach ($pf in $prefFiles) {
        try {
            $prefs = Get-Content -LiteralPath $pf -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            $accts = @($prefs.account_info)
            if ($accts.Count -gt 0 -and ($accts | Where-Object { $_.email })) { return $true }
        }
        catch { continue }
    }
    return $false
}

function Clear-FolderSecurely {
    # Overwrites each file with random bytes, then deletes the folder. Used on the password
    # handoff folder so an exported CSV can't be recovered. On a spinning disk that does the
    # job. On an SSD, wear leveling means the overwrite might not land on the same cells, so
    # treat it as best effort there. Either way the plaintext file is gone.
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $files = @(Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue)
    $count = 0
    foreach ($f in $files) {
        if ($PSCmdlet.ShouldProcess($f.FullName, 'Overwrite and delete')) {
            try {
                $len = [int]$f.Length
                if ($len -gt 0) {
                    $buf = New-Object byte[] $len
                    (New-Object System.Random).NextBytes($buf)
                    [System.IO.File]::WriteAllBytes($f.FullName, $buf)
                }
                Remove-Item -LiteralPath $f.FullName -Force
                $count++
            }
            catch { Write-MigLog "Could not shred $($f.FullName): $($_.Exception.Message)" 'WARN' }
        }
    }
    if ($PSCmdlet.ShouldProcess($Path, 'Remove folder')) {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $count
}

#endregion

try {
    Write-MigLog ('=== Migration CUTOVER started. SkipStaging={0} Force={1} WhatIf={2} ===' -f
        $SkipStaging.IsPresent, $Force.IsPresent, [bool]$WhatIfPreference)

    $profiles = @(Get-UserProfilePath)
    $results = New-Object System.Collections.Generic.List[object]
    $stagedTotal = 0

    foreach ($prof in $profiles) {
        $hasEdge = Test-Path -LiteralPath (Join-Path $prof 'AppData\Local\Microsoft\Edge\User Data')
        $oneDrive = Get-OneDrivePath -ProfilePath $prof
        $edgeReady = Test-EdgeReady -ProfilePath $prof

        #region Stage leftovers
        $stagedHere = 0
        if (-not $SkipStaging -and $oneDrive) {
            foreach ($p in @(Get-Process -Name 'Microsoft.Notes' -ErrorAction SilentlyContinue)) {
                if ($PSCmdlet.ShouldProcess('Microsoft.Notes.exe', 'Stop it so the notes database can be copied')) {
                    $p | Stop-Process -Force -ErrorAction SilentlyContinue
                }
            }
            $stageRoot = Join-Path $oneDrive '_MigrationBackup'
            foreach ($item in Get-MigrationLeftover) {
                $src = Join-Path $prof $item.RelativePath
                if (-not (Test-Path -LiteralPath $src)) { continue }
                $dest = Join-Path $stageRoot $item.RelativePath
                if ($PSCmdlet.ShouldProcess($dest, "Stage $($item.Label)")) {
                    try {
                        $destParent = Split-Path -Path $dest -Parent
                        if (-not (Test-Path -LiteralPath $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }
                        Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force
                        $stagedHere++; $stagedTotal++
                        Write-MigLog "Staged $($item.Label) for $prof"
                    }
                    catch { Write-MigLog "Couldn't stage $($item.Label) for $prof`: $($_.Exception.Message). Something probably has it open." 'WARN' }
                }
            }
        }
        elseif (-not $SkipStaging -and -not $oneDrive -and $hasEdge) {
            Write-MigLog "OneDrive isn't set up for $prof, so nothing got staged. This user is NOT ready." 'WARN'
        }
        #endregion

        # Only users with an Edge profile count toward readiness. No Edge profile, nothing to carry.
        $ready = (-not $hasEdge) -or ($edgeReady -and $oneDrive)
        if ($hasEdge) {
            if ($ready) { Write-MigLog "READY: $prof (Edge signed in, OneDrive present)." }
            else {
                $why = @()
                if (-not $edgeReady) { $why += 'Edge not signed in' }
                if (-not $oneDrive)  { $why += 'OneDrive not set up' }
                Write-MigLog ("NOT READY: $prof - {0}. Have the user open Edge, sign in, confirm sync (edge://sync-internals), and finish OneDrive setup before cutover." -f ($why -join '; ')) 'WARN'
            }
        }
        $results.Add([pscustomobject]@{ Profile = $prof; HasEdge = $hasEdge; EdgeSignedIn = $edgeReady; OneDrive = [bool]$oneDrive; Staged = $stagedHere; Ready = $ready })
    }

    #region Shred the password handoff folder
    $shredded = 0
    if (Test-Path -LiteralPath $HandoffDir) {
        $shredded = Clear-FolderSecurely -Path $HandoffDir
        Write-MigLog "Shredded the password-handoff folder ($shredded file(s) overwritten and deleted)."
    }
    #endregion

    $notReady = @($results | Where-Object { $_.HasEdge -and -not $_.Ready })
    Write-MigLog ('CUTOVER done. Profiles: {0}. Staged {1} item(s). Not ready: {2}. Handoff files shredded: {3}.' -f
        $results.Count, $stagedTotal, $notReady.Count, $shredded)

    [pscustomobject]@{
        Profiles    = $results.ToArray()
        StagedItems = $stagedTotal
        NotReady    = @($notReady | Select-Object -ExpandProperty Profile)
        Shredded    = $shredded
        LogFile     = $LogFile
    } | Format-List | Out-String | Write-Host

    if ($notReady.Count -gt 0 -and -not $Force) {
        Write-MigLog ("Exiting non-zero: {0} user(s) not ready. ProfWiz should hold. Override with -Force." -f $notReady.Count) 'ERROR'
        exit 2
    }
    exit 0
}
catch {
    Write-MigLog "Failed: $($_.Exception.Message)" 'ERROR'
    exit 1
}
