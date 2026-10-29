#Requires -Version 5.1
<#
.SYNOPSIS
    Stages a Windows device and runs a ProfWiz Corporate package for an Entra ID tenant-to-tenant move.

.DESCRIPTION
    Built to run as SYSTEM from an RMM tool. It has three modes.

    Migrate (default)
      1. Saves the computer name and Entra join state to state.json in the working directory.
      2. Downloads the ProfWiz single deployment exe (or uses one already on disk) and can check its
         SHA256 hash.
      3. Registers a failsafe task that lifts the logon block at the next startup, or after
         -FailsafeMinutes, if this script never gets to do it. ProfWiz and the provisioning package can
         both reboot the device on their own, and RMM agents can kill long scripts.
      4. Denies local and RDP sign-in to Everyone, logs off every user session, and waits for the
         profiles to unload so ProfWiz can re-permission them.
      5. Removes MDM enrollment leftovers from the source tenant (registry keys, EnterpriseMgmt tasks,
         Intune MDM device certificate) so the new tenant's bulk enrollment can take over.
      6. Clears Windows Hello containers and the biometric database. Those keys belong to the source
         tenant and get in the way of PIN setup for the new account.
      7. Runs the ProfWiz package, lifts the logon block, removes the startup task, and prints the
         tail of the ProfWiz log.

    PostMigration
      Run after the device has rebooted and joined the new tenant. Renames the device back to the
      name saved in state.json if the provisioning package changed it, and backs up the BitLocker
      recovery key for the system drive to the new tenant.

    UnblockLogon
      Lifts the logon block and removes the startup task. The startup task calls this mode. You can
      also run it from the RMM if a device ever gets stuck at "The sign-in method you're trying to
      use isn't allowed."

    Windows only. Targets Windows PowerShell 5.1 because that is what RMM agents launch on endpoints.
    Relaunches itself in 64-bit PowerShell when a 32-bit agent starts it.

.PARAMETER Mode
    Migrate, PostMigration, or UnblockLogon. Default: Migrate.

.PARAMETER PayloadUrl
    HTTPS URL (usually a blob SAS URL) of the ProfWiz single deployment exe. Defaults to the PayloadUrl
    environment variable, which is how most RMM tools hand script variables to a script.

.PARAMETER PayloadPath
    Path to a ProfWiz exe that is already on the device. Used instead of PayloadUrl.

.PARAMETER PayloadSha256
    Optional SHA256 hash of the ProfWiz exe. The run stops before touching anything if it does not match.

.PARAMETER PayloadArguments
    Optional arguments passed to the ProfWiz exe as-is.

.PARAMETER WorkingDirectory
    Folder for the payload, state.json, logs, and the failsafe copy of this script.
    Default: C:\ProfileMigration.

.PARAMETER ProfWizLogPath
    Where the ProfWiz package writes its log (the <Log> value in profwiz.config). If omitted, the script
    looks for Migrate.log in the working directory and in C:\Users\Public\Documents.

.PARAMETER LogoffTimeoutSeconds
    How long to wait for user profiles to unload after logoff. Default: 120.

.PARAMETER FailsafeMinutes
    The startup task also fires once this many minutes after the block, in case the RMM agent kills the
    script mid-run without a reboot. Set it well above your longest ProfWiz run. Default: 120.

.PARAMETER OriginalComputerName
    PostMigration only. Name to rename the device back to when state.json is missing.

.PARAMETER MdmProviderId
    Migrate only. MDM enrollments to remove, by ProviderID. Default: 'MS DM Server' (Intune).

.PARAMETER SkipLogonBlock
    Migrate only. Do not deny sign-in during the migration. Users are still logged off.

.PARAMETER SkipMdmCleanup
    Migrate only. Leave the source tenant's MDM enrollment in place.

.PARAMETER SkipHelloReset
    Migrate only. Leave Windows Hello containers and biometric data in place.

.PARAMETER SkipRename
    PostMigration only. Do not rename the device.

.PARAMETER SkipBitLockerEscrow
    PostMigration only. Do not back up the BitLocker recovery key to the new tenant.

.PARAMETER Restart
    PostMigration only. Restart after a rename so the name takes effect.

.PARAMETER Force
    UnblockLogon only. Remove both deny rights from Everyone even if state.json says otherwise.

.PARAMETER Verbosity
    Console detail: Low (errors and success), Medium (adds warnings), High (everything). The log file
    always gets everything. Default: High, because RMM output is usually where you read it.

.PARAMETER DryRun
    Runs every check and logs what would change without changing anything or downloading the payload.

.PARAMETER LogPath
    Log file path. Default: <WorkingDirectory>\Logs\<mode>-<timestamp>.log.

.EXAMPLE
    .\invoke-profile-migration.ps1 -PayloadUrl 'https://acct.blob.core.windows.net/profwiz/Migrate.exe?sv=...' -DryRun
    Checks the device and the payload URL and logs every step it would take.

.EXAMPLE
    .\invoke-profile-migration.ps1 -PayloadUrl $url -PayloadSha256 '3F2A...'
    Runs the migration.

.EXAMPLE
    .\invoke-profile-migration.ps1 -Mode PostMigration -Restart
    After the device joins the new tenant, restores its name and escrows the BitLocker key.

.EXAMPLE
    .\invoke-profile-migration.ps1 -Mode UnblockLogon
    Lets users sign in again if a run was interrupted. Add -Force to remove both deny rights no matter what.

.NOTES
    Author:     Christopher Scaminaci
    Version:    2.0.0
    Updated:    2026-09-22
    AI Assist:  Refactored with Claude (Anthropic)
    Requires:   SYSTEM for Migrate. Local admin or SYSTEM for the other modes.
    Exit codes: 0 success, 1 unexpected error, 2 bad parameters, 10 download failed, 20 wrong account or
                not elevated, 30 payload not found, 40 ProfWiz returned non-zero, 50 finished with warnings,
                60 the logon block could not be removed (users cannot sign in, act on this one first).
    Provided as-is with no warranty. Run it on a pilot device before you point it at a fleet.
#>

[CmdletBinding()]
param (
    [ValidateSet('Migrate', 'PostMigration', 'UnblockLogon')]
    [string]$Mode = 'Migrate',

    [string]$PayloadUrl = $env:PayloadUrl,

    [string]$PayloadPath,

    [ValidatePattern('^[A-Fa-f0-9]{64}$')]
    [string]$PayloadSha256,

    [string]$PayloadArguments,

    [ValidateNotNullOrEmpty()]
    [string]$WorkingDirectory = 'C:\ProfileMigration',

    [string]$ProfWizLogPath,

    [ValidateRange(0, 900)]
    [int]$LogoffTimeoutSeconds = 120,

    [ValidateRange(15, 1440)]
    [int]$FailsafeMinutes = 120,

    [ValidatePattern('^(?![0-9]+$)[A-Za-z0-9-]{1,15}$')]
    [string]$OriginalComputerName,

    [string[]]$MdmProviderId = @('MS DM Server'),

    [switch]$SkipLogonBlock,
    [switch]$SkipMdmCleanup,
    [switch]$SkipHelloReset,
    [switch]$SkipRename,
    [switch]$SkipBitLockerEscrow,
    [switch]$Restart,
    [switch]$Force,

    [ValidateSet('Low', 'Medium', 'High')]
    [string]$Verbosity = 'High',

    [switch]$DryRun,

    [string]$LogPath
)

#region Configuration & Constants

function ConvertTo-CommandLineArgument {
    # Quotes one argument by the Windows command-line rules (backslashes before a quote or at the end are
    # doubled). Windows PowerShell 5.1 does not do this for native commands, so paths ending in \ break.
    param ([AllowEmptyString()] [string]$Value)
    if ($Value -and $Value -notmatch '[\s"]') { return $Value }
    $escaped = ($Value -replace '(\\*)"', '$1$1\"') -replace '(\\+)$', '$1$1'
    '"{0}"' -f $escaped
}

# A 32-bit agent sees a redirected HKLM\SOFTWARE and would miss the MDM keys, so hop to 64-bit first.
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $nativePowerShell = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\powershell.exe'
    $relaunchArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
        (ConvertTo-CommandLineArgument $PSCommandPath))
    foreach ($bound in $PSBoundParameters.GetEnumerator()) {
        if ($bound.Value -is [switch]) {
            if ($bound.Value) { $relaunchArgs += "-$($bound.Key)" }
        }
        else {
            # -Name:value keeps a value that starts with "-" from being read as a parameter name. An empty
            # value goes as its own "" argument, because "-Name:" would swallow the next argument.
            $values = @($bound.Value) -join ','
            if ($values -eq '') {
                $relaunchArgs += "-$($bound.Key)"
                $relaunchArgs += '""'
            }
            else {
                $relaunchArgs += '-{0}:{1}' -f $bound.Key, (ConvertTo-CommandLineArgument $values)
            }
        }
    }
    $child = Start-Process -FilePath $nativePowerShell -ArgumentList ($relaunchArgs -join ' ') -NoNewWindow -PassThru
    $null = $child.Handle
    $child.WaitForExit()
    exit $child.ExitCode
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest on 5.1 crawls when it draws a progress bar
$scriptVersion = '2.0.0'
$scriptStart = Get-Date
$script:Verbosity = $Verbosity
$script:DryRun = [bool]$DryRun
$script:exitCode = 0
$script:warnings = New-Object System.Collections.Generic.List[string]
$script:state = $null
$script:failsafeExisted = $false

# A trailing backslash would escape the closing quote in the failsafe task's command line.
if ($WorkingDirectory.Length -gt 3) { $WorkingDirectory = $WorkingDirectory.TrimEnd('\') }
# RMM text fields often hand over "a,b" as one string.
$MdmProviderId = @($MdmProviderId | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } |
    Where-Object { $_ })

$failsafeTaskName = 'ProfileMigration-UnblockLogon'
$everyoneSid = 'S-1-1-0'
$denyRights = @('SeDenyInteractiveLogonRight', 'SeDenyRemoteInteractiveLogonRight')
$statePath = Join-Path $WorkingDirectory 'state.json'
$failsafeScriptPath = Join-Path $WorkingDirectory 'invoke-profile-migration.ps1'

if (-not $LogPath) {
    $logName = '{0}-{1:yyyyMMdd-HHmmss}.log' -f $Mode.ToLower(), $scriptStart
    $LogPath = Join-Path (Join-Path $WorkingDirectory 'Logs') $logName
}
$script:LogPath = $LogPath

# Native user-rights calls. This replaces ntrights.exe, which is a 2003 Resource Kit tool that had to be
# downloaded from a storage account on every run.
$userRightsSource = @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security.Principal;

namespace ProfileMigration
{
    public static class UserRights
    {
        [StructLayout(LayoutKind.Sequential)]
        private struct LSA_UNICODE_STRING
        {
            public ushort Length;
            public ushort MaximumLength;
            public IntPtr Buffer;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct LSA_OBJECT_ATTRIBUTES
        {
            public int Length;
            public IntPtr RootDirectory;
            public IntPtr ObjectName;
            public uint Attributes;
            public IntPtr SecurityDescriptor;
            public IntPtr SecurityQualityOfService;
        }

        [DllImport("advapi32.dll")]
        private static extern uint LsaOpenPolicy(IntPtr systemName, ref LSA_OBJECT_ATTRIBUTES attributes,
            uint desiredAccess, out IntPtr policyHandle);

        [DllImport("advapi32.dll")]
        private static extern uint LsaAddAccountRights(IntPtr policyHandle, byte[] accountSid,
            LSA_UNICODE_STRING[] userRights, uint countOfRights);

        [DllImport("advapi32.dll")]
        private static extern uint LsaRemoveAccountRights(IntPtr policyHandle, byte[] accountSid,
            [MarshalAs(UnmanagedType.U1)] bool allRights, LSA_UNICODE_STRING[] userRights, uint countOfRights);

        [DllImport("advapi32.dll")]
        private static extern uint LsaEnumerateAccountRights(IntPtr policyHandle, byte[] accountSid,
            out IntPtr userRights, out uint countOfRights);

        [DllImport("advapi32.dll")]
        private static extern uint LsaClose(IntPtr policyHandle);

        [DllImport("advapi32.dll")]
        private static extern uint LsaFreeMemory(IntPtr buffer);

        [DllImport("advapi32.dll")]
        private static extern int LsaNtStatusToWinError(uint status);

        // POLICY_VIEW_LOCAL_INFORMATION | POLICY_CREATE_ACCOUNT | POLICY_LOOKUP_NAMES
        private const uint PolicyAccess = 0x00000811;
        private const uint StatusObjectNameNotFound = 0xC0000034;

        private static void Check(uint status)
        {
            if (status != 0) { throw new Win32Exception(LsaNtStatusToWinError(status)); }
        }

        private static IntPtr OpenPolicy()
        {
            LSA_OBJECT_ATTRIBUTES attributes = new LSA_OBJECT_ATTRIBUTES();
            attributes.Length = Marshal.SizeOf(typeof(LSA_OBJECT_ATTRIBUTES));
            IntPtr handle;
            Check(LsaOpenPolicy(IntPtr.Zero, ref attributes, PolicyAccess, out handle));
            return handle;
        }

        private static byte[] SidBytes(string sid)
        {
            SecurityIdentifier identifier = new SecurityIdentifier(sid);
            byte[] bytes = new byte[identifier.BinaryLength];
            identifier.GetBinaryForm(bytes, 0);
            return bytes;
        }

        public static string[] Get(string sid)
        {
            IntPtr handle = OpenPolicy();
            try
            {
                IntPtr buffer;
                uint count;
                uint status = LsaEnumerateAccountRights(handle, SidBytes(sid), out buffer, out count);
                if (status == StatusObjectNameNotFound) { return new string[0]; }
                Check(status);
                try
                {
                    List<string> rights = new List<string>();
                    int size = Marshal.SizeOf(typeof(LSA_UNICODE_STRING));
                    for (int i = 0; i < count; i++)
                    {
                        IntPtr itemPointer = new IntPtr(buffer.ToInt64() + (long)i * size);
                        LSA_UNICODE_STRING item = (LSA_UNICODE_STRING)Marshal.PtrToStructure(
                            itemPointer, typeof(LSA_UNICODE_STRING));
                        rights.Add(Marshal.PtrToStringUni(item.Buffer, item.Length / 2));
                    }
                    return rights.ToArray();
                }
                finally { LsaFreeMemory(buffer); }
            }
            finally { LsaClose(handle); }
        }

        public static void Add(string sid, string right) { Change(sid, right, true); }

        public static void Remove(string sid, string right) { Change(sid, right, false); }

        private static void Change(string sid, string right, bool add)
        {
            LSA_UNICODE_STRING[] rights = new LSA_UNICODE_STRING[1];
            rights[0].Buffer = Marshal.StringToHGlobalUni(right);
            rights[0].Length = (ushort)(right.Length * 2);
            rights[0].MaximumLength = (ushort)((right.Length + 1) * 2);
            IntPtr handle = IntPtr.Zero;
            try
            {
                handle = OpenPolicy();
                uint status = add
                    ? LsaAddAccountRights(handle, SidBytes(sid), rights, 1)
                    : LsaRemoveAccountRights(handle, SidBytes(sid), false, rights, 1);
                if (!add && status == StatusObjectNameNotFound) { return; }
                Check(status);
            }
            finally
            {
                if (handle != IntPtr.Zero) { LsaClose(handle); }
                Marshal.FreeHGlobal(rights[0].Buffer);
            }
        }
    }
}
'@

#endregion

#region Helper Functions

function Write-Log {
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Message,

        [ValidateSet('INFO', 'WARNING', 'ERROR', 'DEBUG', 'SUCCESS')]
        [string]$Level = 'INFO'
    )

    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $Level, $Message
    $show = switch ($script:Verbosity) {
        'Low'    { $Level -in 'ERROR', 'SUCCESS' }
        'Medium' { $Level -in 'ERROR', 'WARNING', 'SUCCESS' }
        default  { $true }
    }
    if ($show) {
        $color = switch ($Level) {
            'ERROR'   { 'Red' }
            'WARNING' { 'Yellow' }
            'SUCCESS' { 'Green' }
            'DEBUG'   { 'Cyan' }
            default   { 'White' }
        }
        Write-Host $line -ForegroundColor $color
    }
    try { Add-Content -Path $script:LogPath -Value $line -ErrorAction Stop } catch { $null = $_ }
}

function Invoke-Action {
    # Every change goes through here so -DryRun can skip it and still log exactly what would happen.
    param (
        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [scriptblock]$Action,

        # Log the failure, count it as a warning (exit 50), and keep going instead of throwing.
        [switch]$ContinueOnError
    )

    if ($script:DryRun) {
        Write-Log "[DRYRUN] Would: $Description"
        return
    }
    Write-Log $Description
    try {
        & $Action
    }
    catch {
        if (-not $ContinueOnError) {
            Write-Log "Failed: $Description. $($_.Exception.Message)" -Level ERROR
            throw
        }
        Write-Log "Failed, continuing: $Description. $($_.Exception.Message)" -Level WARNING
        $script:warnings.Add($Description)
    }
}

function Invoke-Step {
    # Staging steps that should not stop the migration. A failure is logged and the run ends with code 50.
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$Step
    )

    try {
        & $Step
    }
    catch {
        Write-Log "$Name did not finish: $($_.Exception.Message)" -Level WARNING
        $script:warnings.Add($Name)
    }
}

function Invoke-Native {
    # Windows PowerShell 5.1 turns native stderr into terminating errors under 'Stop', so relax it here.
    param (
        [Parameter(Mandatory)]
        [string]$FilePath,

        [string[]]$ArgumentList = @()
    )

    $ErrorActionPreference = 'Continue'
    $output = & $FilePath @ArgumentList 2>&1 | ForEach-Object { "$_" }
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = @($output) }
}

function Hide-SasToken {
    param ([string]$Text)
    if (-not $Text) { return '' }
    $Text -replace '(?i)(sig=)[^&]+', '$1***'
}

function Test-IsSystem {
    [Security.Principal.WindowsIdentity]::GetCurrent().User.Value -eq 'S-1-5-18'
}

function Test-IsAdmin {
    $principal = New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Initialize-WorkingDirectory {
    # Folders under C:\ inherit "Authenticated Users: Modify", and the failsafe runs a script from this one as
    # SYSTEM. So the folder is reset and locked to SYSTEM and Administrators, and ownership moves to
    # Administrators so nothing planted here earlier keeps its owner's rights. Because that rewrite is
    # recursive, it only happens to a folder this kit owns: new, empty, or marked by an earlier run.
    $marker = Join-Path $WorkingDirectory '.profile-migration'
    $ownFolders = @('Logs', 'Inventory', '.profile-migration')
    if (-not (Test-Path -LiteralPath $marker)) {
        $foreign = @(Get-ChildItem -LiteralPath $WorkingDirectory -Force -ErrorAction SilentlyContinue |
            Where-Object { $ownFolders -notcontains $_.Name })
        if ($foreign.Count -gt 0) {
            $script:exitCode = 2
            throw "$WorkingDirectory already holds other files. Point -WorkingDirectory at a dedicated folder."
        }
    }
    Invoke-Action -Description "Restrict $WorkingDirectory to SYSTEM and Administrators" -Action {
        $null = New-Item -Path $WorkingDirectory -ItemType Directory -Force
        $steps = @(
            @($WorkingDirectory, '/reset', '/T', '/C', '/Q'),
            @($WorkingDirectory, '/inheritance:r', '/grant:r', '*S-1-5-18:(OI)(CI)F', '*S-1-5-32-544:(OI)(CI)F',
                '/T', '/C', '/Q'),
            @($WorkingDirectory, '/setowner', '*S-1-5-32-544', '/T', '/C', '/Q')
        )
        foreach ($step in $steps) {
            $result = Invoke-Native -FilePath 'icacls.exe' -ArgumentList $step
            if ($result.ExitCode -ne 0) {
                throw "icacls $($step[1]) returned $($result.ExitCode). $($result.Output -join ' ')"
            }
        }
        Set-Content -LiteralPath $marker -Value 'Working folder for invoke-profile-migration.ps1'
    }
}

function Read-State {
    if (-not (Test-Path -Path $statePath)) { return $null }
    try {
        return (Get-Content -Path $statePath -Raw | ConvertFrom-Json)
    }
    catch {
        Write-Log "state.json could not be read: $($_.Exception.Message)" -Level WARNING
        return $null
    }
}

function Set-StateValue {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [AllowNull()]
        $Value
    )

    if (-not $script:state) { $script:state = [pscustomobject]@{} }
    $script:state | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
    if ($script:DryRun) { return }
    # Write a new file and move it over the old one, so state.json always carries this folder's ACL and a
    # half-written file never replaces a good one.
    $tempState = '{0}.{1}.tmp' -f $statePath, $PID
    $script:state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $tempState -Encoding UTF8
    Move-Item -LiteralPath $tempState -Destination $statePath -Force
}

function Get-JoinState {
    $result = [ordered]@{ AzureAdJoined = 'NO'; DomainJoined = 'NO'; TenantName = ''; TenantId = ''; DeviceId = '' }
    $dsreg = Invoke-Native -FilePath (Join-Path $env:WINDIR 'System32\dsregcmd.exe') -ArgumentList '/status'
    foreach ($line in $dsreg.Output) {
        if ($line -match '^\s*(AzureAdJoined|DomainJoined|TenantName|TenantId|DeviceId)\s*:\s*(.*?)\s*$') {
            $result[$Matches[1]] = $Matches[2]
        }
    }
    [pscustomobject]$result
}

function Initialize-UserRightsType {
    if (-not ('ProfileMigration.UserRights' -as [type])) {
        Add-Type -TypeDefinition $userRightsSource -Language CSharp
    }
}

#endregion

#region Main Functions

function Request-Payload {
    if ($PayloadPath) {
        if (-not (Test-Path -Path $PayloadPath -PathType Leaf)) {
            $script:exitCode = 30
            throw "PayloadPath $PayloadPath does not exist."
        }
        $source = (Resolve-Path -Path $PayloadPath).Path
        $file = Join-Path $WorkingDirectory (Split-Path -Path $source -Leaf)
        if ($source -ne $file) {
            # Run a fresh copy from the locked folder, not a file wherever the RMM happened to drop it.
            Invoke-Action -Description "Copy payload $source to $file" -Action {
                if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
                Copy-Item -LiteralPath $source -Destination $file
            }
            if ($script:DryRun) { $file = $source }
        }
        Write-Log "Using the payload already on disk: $file"
    }
    else {
        $uri = $null
        if (-not [Uri]::TryCreate($PayloadUrl, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
            $script:exitCode = 2
            throw 'PayloadUrl must be an absolute https URL.'
        }
        $name = [IO.Path]::GetFileName($uri.AbsolutePath)
        if ($name -notmatch '\.exe$') { $name = 'profwiz-payload.exe' }
        $file = Join-Path $WorkingDirectory $name

        if ($script:DryRun) {
            try {
                $null = Invoke-WebRequest -Uri $PayloadUrl -Method Head -UseBasicParsing -TimeoutSec 60
                Write-Log "[DRYRUN] Payload URL answered. Would download it to $file"
            }
            catch {
                Write-Log "[DRYRUN] Payload URL check failed: $($_.Exception.Message)" -Level WARNING
                $script:warnings.Add('Payload URL check')
            }
            return $file
        }

        Write-Log "Downloading payload from $(Hide-SasToken $PayloadUrl)"
        # A fresh file is owned by SYSTEM. Overwriting in place would keep whoever owned the old one.
        if (Test-Path -Path $file) { Remove-Item -Path $file -Force }
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                Invoke-WebRequest -Uri $PayloadUrl -OutFile $file -UseBasicParsing -TimeoutSec 900
                break
            }
            catch {
                if ($attempt -eq 3) {
                    $script:exitCode = 10
                    throw "Payload download failed after 3 attempts: $($_.Exception.Message)"
                }
                Write-Log "Download attempt $attempt failed: $($_.Exception.Message). Retrying." -Level WARNING
                Start-Sleep -Seconds (10 * $attempt)
            }
        }
    }

    $item = Get-Item -Path $file
    if ($item.Length -eq 0) {
        $script:exitCode = 30
        throw "Payload $file is empty."
    }
    Write-Log ('Payload is {0:N1} MB' -f ($item.Length / 1MB))

    if ($PayloadSha256) {
        $hash = (Get-FileHash -Path $file -Algorithm SHA256).Hash
        if ($hash -ne $PayloadSha256.ToUpperInvariant()) {
            $script:exitCode = 2
            throw "Payload hash $hash does not match the expected $PayloadSha256."
        }
        Write-Log 'Payload SHA256 matches' -Level SUCCESS
    }

    $signature = Get-AuthenticodeSignature -FilePath $file
    $signer = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { 'none' }
    Write-Log "Payload signature: $($signature.Status), signer: $signer"
    return $file
}

function Register-Failsafe {
    if (-not $PSCommandPath) {
        throw 'The failsafe needs this script to run from a file. Run it as a .ps1, or use -SkipLogonBlock.'
    }
    $description = "Register failsafe task '$failsafeTaskName' (at startup, or in $FailsafeMinutes minutes)"
    Invoke-Action -Description $description -Action {
        if ($PSCommandPath -ne $failsafeScriptPath) {
            if (Test-Path -Path $failsafeScriptPath) { Remove-Item -Path $failsafeScriptPath -Force }
            Copy-Item -Path $PSCommandPath -Destination $failsafeScriptPath
        }
        $powershellExe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $taskArgs = ('-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}" -Mode UnblockLogon ' +
            '-WorkingDirectory "{1}"') -f $failsafeScriptPath, $WorkingDirectory
        $taskAction = New-ScheduledTaskAction -Execute $powershellExe -Argument $taskArgs
        $taskTrigger = @(
            New-ScheduledTaskTrigger -AtStartup
            New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes($FailsafeMinutes)
        )
        $taskPrincipal = New-ScheduledTaskPrincipal -UserId 'S-1-5-18' -LogonType ServiceAccount -RunLevel Highest
        $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) `
            -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
        $taskParams = @{
            TaskName  = $failsafeTaskName
            Action    = $taskAction
            Trigger   = $taskTrigger
            Principal = $taskPrincipal
            Settings  = $taskSettings
            Force     = $true
        }
        $null = Register-ScheduledTask @taskParams
    }
}

function Unregister-Failsafe {
    if (Get-ScheduledTask -TaskName $failsafeTaskName -ErrorAction SilentlyContinue) {
        Invoke-Action -Description "Remove startup task '$failsafeTaskName'" -Action {
            Unregister-ScheduledTask -TaskName $failsafeTaskName -Confirm:$false
        }
    }
}

function Block-Logon {
    $current = @([ProfileMigration.UserRights]::Get($everyoneSid))
    # Rights an earlier, interrupted run added are still ours to remove. Only rights Everyone had before this
    # kit ever touched the device are left alone.
    $earlier = @()
    if ($script:state -and $script:state.PSObject.Properties['AddedDenyRights']) {
        $earlier = @($script:state.AddedDenyRights | Where-Object { $_ })
    }
    if ($script:failsafeExisted) { $earlier = @($earlier + $current | Select-Object -Unique) }
    $preExisting = @($denyRights | Where-Object { $current -contains $_ -and $earlier -notcontains $_ })
    foreach ($right in $preExisting) {
        Write-Log "Everyone already had $right before this run. It will be left in place afterward." -Level WARNING
    }
    $ours = @($denyRights | Where-Object { $preExisting -notcontains $_ })
    $toAdd = @($ours | Where-Object { $current -notcontains $_ })

    # Record what we own before adding anything, so an interrupted run still gets cleaned up.
    Set-StateValue -Name 'AddedDenyRights' -Value $ours
    foreach ($right in $toAdd) {
        Invoke-Action -Description "Deny $right to Everyone" -Action {
            [ProfileMigration.UserRights]::Add($everyoneSid, $right)
        }
    }
}

function Unblock-Logon {
    param ([string[]]$Rights = $denyRights)

    $failed = $false
    foreach ($right in $Rights) {
        try {
            Invoke-Action -Description "Remove $right from Everyone" -Action {
                [ProfileMigration.UserRights]::Remove($everyoneSid, $right)
            }
        }
        catch {
            $failed = $true
        }
    }
    if ($failed) {
        Write-Log 'Logon block not fully removed. The failsafe task stays so the next boot tries again.' -Level ERROR
        $script:exitCode = 60
        return
    }
    Set-StateValue -Name 'AddedDenyRights' -Value @()
    if (-not $script:DryRun) { Write-Log 'Users can sign in again' -Level SUCCESS }
    Unregister-Failsafe
}

function Close-UserSession {
    # explorer.exe runs in every interactive session, including disconnected RDP sessions. This avoids
    # parsing quser output, which changes with the OS language.
    $sessionIds = @(Get-CimInstance -ClassName Win32_Process -Filter "Name = 'explorer.exe'" |
        Where-Object { $_.SessionId -gt 0 } |
        Select-Object -ExpandProperty SessionId -Unique)

    if ($sessionIds.Count -eq 0) { Write-Log 'No interactive user sessions found' }
    $logoffExe = Join-Path $env:WINDIR 'System32\logoff.exe'
    foreach ($sessionId in $sessionIds) {
        Invoke-Action -Description "Log off session $sessionId" -ContinueOnError -Action {
            $result = Invoke-Native -FilePath $logoffExe -ArgumentList "$sessionId"
            if ($result.ExitCode -ne 0) { throw "logoff.exe returned $($result.ExitCode). $($result.Output -join ' ')" }
        }
    }

    if ($script:DryRun -or $LogoffTimeoutSeconds -eq 0) { return }
    $deadline = (Get-Date).AddSeconds($LogoffTimeoutSeconds)
    do {
        $loaded = @(Get-CimInstance -ClassName Win32_UserProfile -Filter 'Special = FALSE AND Loaded = TRUE')
        if ($loaded.Count -eq 0) {
            Write-Log 'All user profiles are unloaded' -Level SUCCESS
            return
        }
        Start-Sleep -Seconds 5
    } while ((Get-Date) -lt $deadline)
    Write-Log ('Still loaded after {0}s: {1}. ProfWiz may skip these.' -f $LogoffTimeoutSeconds,
        ($loaded.LocalPath -join ', ')) -Level WARNING
    $script:warnings.Add('Profiles still loaded')
}

function Get-MdmEnrollmentId {
    # Only enrollments from the providers in -MdmProviderId (Intune is "MS DM Server"). Co-management and
    # other WMI bridge enrollments carry different provider IDs and are left alone.
    $guidPattern = '^\{?[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}\}?$'
    Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Enrollments' -ErrorAction SilentlyContinue |
        Where-Object { $_.PSChildName -match $guidPattern -and $MdmProviderId -contains $_.GetValue('ProviderID') } |
        ForEach-Object { $_.PSChildName } |
        Sort-Object -Unique
}

function Remove-MdmEnrollment {
    $ids = @(Get-MdmEnrollmentId)
    if ($ids.Count -eq 0) { Write-Log 'No MDM enrollments found' }

    $keyRoots = @(
        'HKLM:\SOFTWARE\Microsoft\Enrollments'
        'HKLM:\SOFTWARE\Microsoft\Enrollments\Status'
        'HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked'
        'HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled'
        'HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers'
        'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts'
        'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger'
        'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions'
    )
    $scheduler = New-Object -ComObject Schedule.Service
    $scheduler.Connect()

    foreach ($id in $ids) {
        $enrollmentKey = "HKLM:\SOFTWARE\Microsoft\Enrollments\$id"
        $provider = (Get-ItemProperty -Path $enrollmentKey -ErrorAction SilentlyContinue).ProviderID
        Write-Log "MDM enrollment $id (provider: $provider)"
        foreach ($root in $keyRoots) {
            $key = Join-Path $root $id
            if (Test-Path -Path $key) {
                Invoke-Action -Description "Delete $key" -ContinueOnError -Action {
                    Remove-Item -Path $key -Recurse -Force
                }
            }
        }

        $taskPath = "\Microsoft\Windows\EnterpriseMgmt\$id\"
        foreach ($task in @(Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue)) {
            Invoke-Action -Description "Unregister task $taskPath$($task.TaskName)" -ContinueOnError -Action {
                Unregister-ScheduledTask -InputObject $task -Confirm:$false
            }
        }
        $folder = $null
        try { $folder = $scheduler.GetFolder($taskPath.TrimEnd('\')) } catch { $null = $_ }
        if ($folder) {
            Invoke-Action -Description "Delete task folder $taskPath" -ContinueOnError -Action {
                $scheduler.GetFolder('\Microsoft\Windows\EnterpriseMgmt').DeleteFolder($id, 0)
            }
        }
    }

    $mdmCerts = @(Get-ChildItem -Path 'Cert:\LocalMachine\My' |
        Where-Object { $_.Issuer -match 'Microsoft Intune MDM Device CA' })
    foreach ($cert in $mdmCerts) {
        Invoke-Action -Description "Remove Intune MDM device certificate $($cert.Thumbprint)" -ContinueOnError -Action {
            Remove-Item -Path $cert.PSPath -Force
        }
    }
}

function Reset-WindowsHello {
    $ngcPath = Join-Path $env:WINDIR 'ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc'
    if (Test-Path -Path $ngcPath) {
        Invoke-Action -Description "Clear Windows Hello containers in $ngcPath" -ContinueOnError -Action {
            try {
                Get-ChildItem -Path $ngcPath -Force | Remove-Item -Recurse -Force
            }
            catch {
                # SYSTEM can normally delete these. An admin token needs ownership first. The group SID keeps
                # icacls working on non-English Windows. takeown's /d answer is English-only (Y), which is
                # fine here because this path only runs when the direct delete fails.
                Write-Log "Direct delete failed ($($_.Exception.Message)). Taking ownership, retrying." -Level WARNING
                $null = Invoke-Native -FilePath 'takeown.exe' -ArgumentList @('/f', $ngcPath, '/r', '/d', 'y')
                $grantArgs = @($ngcPath, '/grant', '*S-1-5-32-544:F', '/t', '/c', '/q')
                $null = Invoke-Native -FilePath 'icacls.exe' -ArgumentList $grantArgs
                Get-ChildItem -Path $ngcPath -Force | Remove-Item -Recurse -Force
                $null = Invoke-Native -FilePath 'icacls.exe' -ArgumentList @($ngcPath, '/reset', '/t', '/c', '/q')
            }
        }
    }
    else {
        Write-Log 'No Windows Hello container folder found'
    }

    $bioPath = Join-Path $env:WINDIR 'System32\WinBioDatabase'
    if ((Get-Service -Name 'WbioSrvc' -ErrorAction SilentlyContinue) -and (Test-Path -Path $bioPath)) {
        Invoke-Action -Description "Clear biometric enrollments in $bioPath" -ContinueOnError -Action {
            Stop-Service -Name 'WbioSrvc' -Force
            try {
                Get-ChildItem -Path $bioPath -File -Force | Remove-Item -Force
            }
            finally {
                Start-Service -Name 'WbioSrvc'
            }
        }
    }
}

function Start-Payload {
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $script:payloadExitCode = 0
    $startParams = @{ FilePath = $FilePath; WorkingDirectory = $WorkingDirectory; PassThru = $true }
    if ($PayloadArguments) { $startParams.ArgumentList = $PayloadArguments }

    Invoke-Action -Description "Run ProfWiz package $FilePath $PayloadArguments" -Action {
        $process = Start-Process @startParams
        $null = $process.Handle   # without this, ExitCode can come back empty on 5.1
        $process.WaitForExit()
        $script:payloadExitCode = $process.ExitCode
    }
    if ($script:DryRun) {
        Write-Log '[DRYRUN] ProfWiz was not run'
    }
    elseif ($script:payloadExitCode -eq 0) {
        Write-Log 'ProfWiz exited with code 0' -Level SUCCESS
    }
    else {
        Write-Log "ProfWiz exited with code $($script:payloadExitCode). Check the ProfWiz log below." -Level ERROR
    }
}

function Show-ProfWizLog {
    $candidates = @($ProfWizLogPath, (Join-Path $WorkingDirectory 'Migrate.log'),
        (Join-Path $env:PUBLIC 'Documents\Migrate.log')) | Where-Object { $_ }
    $profWizLog = $candidates | Where-Object { Test-Path -Path $_ -PathType Leaf } | Select-Object -First 1
    if (-not $profWizLog) {
        Write-Log "No ProfWiz log found. Looked in: $($candidates -join '; ')" -Level WARNING
        return
    }
    $logItem = Get-Item -Path $profWizLog
    Write-Log "ProfWiz log $profWizLog (last written $($logItem.LastWriteTime)). Last 100 lines:"
    Get-Content -Path $profWizLog -Tail 100 | ForEach-Object { Write-Log "  profwiz | $_" }
}

function Restore-ComputerName {
    $target = $OriginalComputerName
    if (-not $target -and $script:state) { $target = "$($script:state.OriginalComputerName)" }
    if (-not $target) {
        Write-Log 'No original computer name on record (state.json missing). Pass -OriginalComputerName.' -Level WARNING
        $script:warnings.Add('Rename')
        return
    }
    if ($target -notmatch '^(?![0-9]+$)[A-Za-z0-9-]{1,15}$') {
        Write-Log "'$target' is not a valid computer name. Pass -OriginalComputerName." -Level WARNING
        $script:warnings.Add('Rename')
        return
    }

    $current = $env:COMPUTERNAME
    $pendingKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'
    $pending = (Get-ItemProperty -Path $pendingKey).ComputerName
    if ($current -eq $target) {
        if ($pending -ne $target) {
            Write-Log "Name is $target but a rename to $pending is pending. Reboot and run this again." -Level WARNING
            $script:warnings.Add('Rename')
        }
        else {
            Write-Log "Computer name is already $target" -Level SUCCESS
        }
        return
    }
    if ($pending -eq $target) {
        Write-Log "Rename to $target is already pending and applies at the next restart"
        $script:renamePending = $true
        return
    }
    Invoke-Action -Description "Rename computer from $current to $target" -Action {
        Rename-Computer -NewName $target -Force -WarningAction SilentlyContinue
    }
    $script:renamePending = $true
}

function Backup-BitLockerKey {
    $join = Get-JoinState
    if ($join.AzureAdJoined -ne 'YES') {
        Write-Log 'Device is not Entra joined yet. Run PostMigration again once the join finishes.' -Level WARNING
        $script:warnings.Add('BitLocker escrow')
        return
    }
    if (-not (Get-Command -Name 'BackupToAAD-BitLockerKeyProtector' -ErrorAction SilentlyContinue)) {
        Write-Log 'BitLocker cmdlets are not available on this edition. Skipping key backup.'
        return
    }
    $volume = Get-BitLockerVolume -MountPoint $env:SystemDrive
    if ($volume.VolumeStatus -eq 'FullyDecrypted') {
        Write-Log "$env:SystemDrive is not encrypted. Nothing to back up."
        return
    }
    $protectors = @($volume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' })
    if ($protectors.Count -eq 0) {
        Write-Log "$env:SystemDrive has no recovery password protector to back up" -Level WARNING
        $script:warnings.Add('BitLocker escrow')
        return
    }
    foreach ($protector in $protectors) {
        $keyId = $protector.KeyProtectorId
        Invoke-Action -Description "Back up recovery key $keyId to tenant $($join.TenantName)" -Action {
            $null = BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $keyId
        }
    }
}

function Invoke-MigrateMode {
    if (-not (Test-IsSystem)) {
        $script:exitCode = 20
        throw 'Migrate mode must run as SYSTEM (RMM, Intune, or psexec -s). A user session would log itself off.'
    }
    if (-not $PayloadUrl -and -not $PayloadPath) {
        $script:exitCode = 2
        throw 'No payload. Pass -PayloadUrl (or set a PayloadUrl RMM variable) or -PayloadPath.'
    }
    Initialize-WorkingDirectory

    if (-not $script:state.OriginalComputerName) {
        Set-StateValue -Name 'OriginalComputerName' -Value $env:COMPUTERNAME
    }
    $joinBefore = Get-JoinState
    Write-Log ('Join state: EntraJoined={0} DomainJoined={1} Tenant={2}' -f $joinBefore.AzureAdJoined,
        $joinBefore.DomainJoined, $joinBefore.TenantName)
    Set-StateValue -Name 'JoinStateBefore' -Value $joinBefore
    Set-StateValue -Name 'LastRun' -Value (Get-Date).ToString('o')

    # Download before blocking sign-in so users are not locked out while a slow link pulls the payload.
    $payload = Request-Payload

    $blocked = $false
    try {
        if ($SkipLogonBlock) {
            Write-Log 'Skipping the logon block (-SkipLogonBlock). Users can sign back in mid-run.' -Level WARNING
        }
        else {
            Initialize-UserRightsType
            # A failsafe task left by an interrupted run means any deny rights Everyone has now are ours, even
            # if state.json is gone.
            $leftover = Get-ScheduledTask -TaskName $failsafeTaskName -ErrorAction SilentlyContinue
            $script:failsafeExisted = [bool]$leftover
            Register-Failsafe
            $blocked = $true
            Block-Logon
        }
        Close-UserSession

        if ($SkipMdmCleanup) { Write-Log 'Skipping MDM cleanup (-SkipMdmCleanup)' }
        else { Invoke-Step -Name 'MDM cleanup' -Step { Remove-MdmEnrollment } }

        if ($SkipHelloReset) { Write-Log 'Skipping Windows Hello reset (-SkipHelloReset)' }
        else { Invoke-Step -Name 'Windows Hello reset' -Step { Reset-WindowsHello } }

        Start-Payload -FilePath $payload
    }
    finally {
        if ($blocked) {
            $added = @($script:state.AddedDenyRights | Where-Object { $_ })
            Unblock-Logon -Rights $added
        }
        Show-ProfWizLog
    }

    if ($script:payloadExitCode -ne 0 -and $script:exitCode -eq 0) { $script:exitCode = 40 }
}

function Invoke-PostMigrationMode {
    if (-not (Test-IsAdmin)) {
        $script:exitCode = 20
        throw 'PostMigration mode needs SYSTEM or an elevated admin.'
    }
    $script:renamePending = $false
    # Escrow first. A rename can fail or restart the device, and the key must not wait on it.
    if ($SkipBitLockerEscrow) { Write-Log 'Skipping BitLocker key backup (-SkipBitLockerEscrow)' }
    else { Invoke-Step -Name 'BitLocker escrow' -Step { Backup-BitLockerKey } }
    if ($SkipRename) { Write-Log 'Skipping rename (-SkipRename)' }
    else { Invoke-Step -Name 'Rename' -Step { Restore-ComputerName } }

    if ($script:renamePending) {
        if ($Restart) {
            Invoke-Action -Description 'Restart the device in 60 seconds to apply the new name' -Action {
                $null = Invoke-Native -FilePath 'shutdown.exe' -ArgumentList @('/r', '/t', '60', '/c',
                    'Restarting to finish the computer rename.')
            }
        }
        else {
            Write-Log 'The new name applies at the next restart' -Level WARNING
        }
    }
}

function Invoke-UnblockLogonMode {
    if (-not (Test-IsAdmin)) {
        $script:exitCode = 20
        throw 'UnblockLogon mode needs SYSTEM or an elevated admin.'
    }
    Initialize-UserRightsType
    $rights = $denyRights
    if (-not $Force -and $script:state -and $script:state.PSObject.Properties['AddedDenyRights']) {
        $rights = @($script:state.AddedDenyRights | Where-Object { $_ })
    }
    Write-Log "Rights to remove from Everyone: $(if ($rights) { $rights -join ', ' } else { 'none' })"
    Unblock-Logon -Rights $rights
}

#endregion

#region Script Body

try {
    if ($WorkingDirectory -match '^[A-Za-z]:\\?$') {
        $script:exitCode = 2
        throw 'WorkingDirectory cannot be the root of a drive.'
    }
    $null = New-Item -Path (Split-Path -Path $script:LogPath -Parent) -ItemType Directory -Force
    $runAs = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Log "invoke-profile-migration.ps1 $scriptVersion | Mode=$Mode | $env:COMPUTERNAME | $runAs"
    Write-Log ("Parameters: " + (($PSBoundParameters.GetEnumerator() | ForEach-Object {
        '{0}={1}' -f $_.Key, (Hide-SasToken "$($_.Value)") }) -join ' '))
    if ($PayloadUrl -and -not $PSBoundParameters.ContainsKey('PayloadUrl')) {
        Write-Log "PayloadUrl from environment: $(Hide-SasToken $PayloadUrl)"
    }
    if ($script:DryRun) { Write-Log '*** DRY RUN: nothing will be changed ***' -Level WARNING }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12
    $script:state = Read-State

    switch ($Mode) {
        'Migrate'       { Invoke-MigrateMode }
        'PostMigration' { Invoke-PostMigrationMode }
        'UnblockLogon'  { Invoke-UnblockLogonMode }
    }

    if ($script:exitCode -eq 0 -and $script:warnings.Count -gt 0) { $script:exitCode = 50 }
    if ($script:exitCode -eq 0) {
        Write-Log "$Mode finished" -Level SUCCESS
    }
    elseif ($script:exitCode -eq 50) {
        Write-Log "$Mode finished with warnings: $($script:warnings -join ', ')" -Level WARNING
    }
    else {
        Write-Log "$Mode finished with exit code $($script:exitCode)" -Level ERROR
    }
}
catch {
    Write-Log "Stopped: $($_.Exception.Message)" -Level ERROR
    Write-Log "At: $($_.ScriptStackTrace)" -Level DEBUG
    if ($script:exitCode -eq 0) { $script:exitCode = 1 }
}
finally {
    Write-Log ('Duration {0:hh\:mm\:ss}. Log: {1}' -f ((Get-Date) - $scriptStart), $script:LogPath)
}

exit $script:exitCode

#endregion
