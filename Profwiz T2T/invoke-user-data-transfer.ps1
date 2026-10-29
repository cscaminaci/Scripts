#Requires -Version 5.1
<#
.SYNOPSIS
    Backs up (or restores) the user data that OneDrive does not sync on its own, for a tenant-to-tenant move.

.DESCRIPTION
    Run as the signed-in user, not SYSTEM. OneDrive Known Folder Move covers Desktop, Documents, and
    Pictures. This covers what lives in AppData and would otherwise depend on ProfWiz alone:

      Chrome            %LOCALAPPDATA%\Google\Chrome\User Data (caches skipped)
      Edge              %LOCALAPPDATA%\Microsoft\Edge\User Data (caches skipped)
      Firefox           %APPDATA%\Mozilla\Firefox
      StickyNotes       Sticky Notes LocalState folder (database plus its -wal and -shm files)
      OutlookSignatures %APPDATA%\Microsoft\Signatures
      SavedLogins       Credential Manager entries, including the stored secrets, exported to a CSV and
                        written back into the new account's Credential Manager on restore.

    Backup also sets the Edge ForceSync policy (HKCU) so Edge syncs the user's favorites, passwords, and
    settings from their account after the move.

    Backup zips each item into <OneDrive>\ProfileMigrationBackup\<COMPUTER>_<USER>\ (or the same folder
    inside the profile with -Storage Local) and writes a manifest.json. Zips are built in %TEMP% and moved in
    when complete, so OneDrive never uploads a half-written file.

    Restore finds the newest matching backup in the current OneDrive, in any older "OneDrive - *" folder
    still in the profile, or in the local folder. It moves each existing folder aside as
    <folder>.pre-restore-<timestamp> before extracting, so nothing is deleted. SavedLogins are written back
    into Credential Manager.

    SavedLogins.csv holds the stored secrets in clear text. It sits in the backup folder, so treat that folder
    (and the OneDrive it syncs to) as sensitive. Browser passwords and cookies are a separate matter: Chrome
    and Edge encrypt those to the old account (DPAPI), so they will not open for the new account. Turn on Edge
    or browser sync, or export browser passwords, before the move.

    Windows only. Targets Windows PowerShell 5.1.

.PARAMETER Mode
    Backup or Restore.

.PARAMETER Storage
    OneDrive (default) or Local.

.PARAMETER BackupPath
    Exact backup folder to write to (Backup) or read from (Restore). Overrides the automatic choice.

.PARAMETER LocalRoot
    Root folder for -Storage Local. Default: %USERPROFILE%\ProfileMigrationBackup. It sits inside the profile
    so other users cannot read it, and ProfWiz hands it to the new account along with the rest of the
    profile. A shared folder such as C:\ProfileBackup would expose things like Firefox's saved passwords.

.PARAMETER Item
    Which items to process. Default: all of them.

.PARAMETER CloseApps
    Close the browsers and Sticky Notes first. Backup copies of open browser databases can be inconsistent,
    and Restore skips any app that is still running because it would overwrite the restored files on exit.

.PARAMETER Verbosity
    Console detail: Low, Medium, or High. The log file always gets everything. Default: High.

.PARAMETER DryRun
    Finds the source and target folders and logs what would happen without writing anything.

.PARAMETER LogPath
    Log file path. Default: %LOCALAPPDATA%\ProfileMigration\Logs\user-data-<mode>-<timestamp>.log.

.EXAMPLE
    .\invoke-user-data-transfer.ps1 -Mode Backup -DryRun

.EXAMPLE
    .\invoke-user-data-transfer.ps1 -Mode Backup -CloseApps

.EXAMPLE
    .\invoke-user-data-transfer.ps1 -Mode Restore -CloseApps -Item Chrome, StickyNotes

.NOTES
    Author:     Christopher Scaminaci
    Version:    2.0.0
    Updated:    2026-09-22
    AI Assist:  Refactored with Claude (Anthropic)
    Requires:   Runs as the signed-in user. No admin rights and no extra modules.
    Exit codes: 0 success, 1 unexpected error, 2 bad parameters, 20 running as SYSTEM, 30 OneDrive or backup
                not found, 50 finished with warnings (an item was skipped or had unreadable files).
    Provided as-is with no warranty.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet('Backup', 'Restore')]
    [string]$Mode,

    [ValidateSet('OneDrive', 'Local')]
    [string]$Storage = 'OneDrive',

    [string]$BackupPath,

    [ValidateNotNullOrEmpty()]
    [string]$LocalRoot = (Join-Path $env:USERPROFILE 'ProfileMigrationBackup'),

    [ValidateSet('Chrome', 'Edge', 'Firefox', 'StickyNotes', 'OutlookSignatures', 'SavedLogins')]
    [string[]]$Item = @('Chrome', 'Edge', 'Firefox', 'StickyNotes', 'OutlookSignatures', 'SavedLogins'),

    [switch]$CloseApps,

    [ValidateSet('Low', 'Medium', 'High')]
    [string]$Verbosity = 'High',

    [switch]$DryRun,

    [string]$LogPath
)

#region Configuration & Constants

$ErrorActionPreference = 'Stop'
$scriptVersion = '2.0.0'
$scriptStart = Get-Date
$script:Verbosity = $Verbosity
$script:DryRun = [bool]$DryRun
$script:exitCode = 0
$script:warnings = New-Object System.Collections.Generic.List[string]
$script:backupTarget = $null
$backupFolderName = 'ProfileMigrationBackup'
$setName = '{0}_{1}' -f $env:COMPUTERNAME, $env:USERNAME

if (-not $LogPath) {
    $logName = 'user-data-{0}-{1:yyyyMMdd-HHmmss}.log' -f $Mode.ToLower(), $scriptStart
    $LogPath = Join-Path (Join-Path $env:LOCALAPPDATA 'ProfileMigration\Logs') $logName
}
$script:LogPath = $LogPath

# Folders that browsers rebuild on their own. Skipping them keeps the zips small and the backup fast.
$chromiumSkip = @('Cache', 'Code Cache', 'GPUCache', 'DawnCache', 'DawnGraphiteCache', 'DawnWebGPUCache',
    'GrShaderCache', 'GraphiteDawnCache', 'ShaderCache', 'CacheStorage', 'ScriptCache', 'Crashpad',
    'BrowserMetrics', 'component_crx_cache', 'extensions_crx_cache', 'optimization_guide_model_store',
    'OptGuideOnDeviceModel', 'Safe Browsing', 'Snapshots', 'screen_ai', 'SODA', 'WidevineCdm')
$firefoxSkip = @('cache2', 'startupCache', 'shader-cache', 'minidumps', 'crashes', 'Crash Reports',
    'Pending Pings', 'saved-telemetry-pings', 'datareporting')

# RequireParent: only restore into an app folder Windows has already created for this account. Creating
# an AppX package folder by hand can leave the app unable to start.
$catalog = @{
    Chrome            = @{
        Path    = '%LOCALAPPDATA%\Google\Chrome\User Data'
        Process = 'chrome'
        Skip    = $chromiumSkip
    }
    Edge              = @{
        Path    = '%LOCALAPPDATA%\Microsoft\Edge\User Data'
        Process = 'msedge'
        Skip    = $chromiumSkip
    }
    Firefox           = @{ Path = '%APPDATA%\Mozilla\Firefox'; Process = 'firefox'; Skip = $firefoxSkip }
    StickyNotes       = @{
        Path          = '%LOCALAPPDATA%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState'
        Process       = 'Microsoft.Notes'
        Skip          = @()
        RequireParent = $true
    }
    OutlookSignatures = @{ Path = '%APPDATA%\Microsoft\Signatures'; Process = $null; Skip = @() }
}

# Credential Manager entries that belong to the old tenant's sign-in and will be recreated by the new one.
$credentialNoise = '^(MicrosoftOffice\d+_Data|MicrosoftAccount:|OneDrive Cached Credential|msteams|MSTeams|' +
    'virtualapp/didlogical|WindowsLive:|SSO_POP_|Xbl|Microsoft_OC1|AzureAD|WindowsHello)'

# Credential Manager backup and restore. This reads the stored secrets and writes them back into the new
# account's Credential Manager, so mapped drives, RDP hosts, and app logins keep working after the move.
$credentialSource = @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace ProfileMigration
{
    public class SavedCredential
    {
        public string Target;
        public string Type;
        public uint TypeCode;
        public string UserName;
        public string Persist;
        public uint PersistCode;
        public string Secret;
        public DateTime LastWritten;
    }

    public static class CredentialList
    {
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct CREDENTIAL
        {
            public uint Flags;
            public uint Type;
            public string TargetName;
            public string Comment;
            public uint LastWrittenLow;
            public uint LastWrittenHigh;
            public uint CredentialBlobSize;
            public IntPtr CredentialBlob;
            public uint Persist;
            public uint AttributeCount;
            public IntPtr Attributes;
            public string TargetAlias;
            public string UserName;
        }

        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredEnumerate(string filter, uint flags, out uint count,
            out IntPtr credentials);

        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CredWrite(ref CREDENTIAL credential, uint flags);

        [DllImport("advapi32.dll")]
        private static extern void CredFree(IntPtr buffer);

        private static readonly string[] TypeNames = { "Unknown", "Generic", "DomainPassword",
            "DomainCertificate", "DomainVisiblePassword", "GenericCertificate", "DomainExtended" };
        private static readonly string[] PersistNames = { "Unknown", "Session", "LocalMachine", "Enterprise" };

        public static SavedCredential[] Get()
        {
            uint count;
            IntPtr buffer;
            // Flag 1 is CRED_ENUMERATE_ALL_CREDENTIALS. Error 1168 means there are none.
            if (!CredEnumerate(null, 1, out count, out buffer))
            {
                int error = Marshal.GetLastWin32Error();
                if (error == 1168) { return new SavedCredential[0]; }
                throw new Win32Exception(error);
            }
            try
            {
                List<SavedCredential> list = new List<SavedCredential>();
                for (int i = 0; i < count; i++)
                {
                    IntPtr itemPointer = Marshal.ReadIntPtr(buffer, i * IntPtr.Size);
                    CREDENTIAL item = (CREDENTIAL)Marshal.PtrToStructure(itemPointer, typeof(CREDENTIAL));
                    SavedCredential entry = new SavedCredential();
                    entry.Target = item.TargetName;
                    entry.UserName = item.UserName;
                    entry.TypeCode = item.Type;
                    entry.PersistCode = item.Persist;
                    entry.Type = item.Type < TypeNames.Length ? TypeNames[item.Type] : item.Type.ToString();
                    entry.Persist = item.Persist < PersistNames.Length
                        ? PersistNames[item.Persist] : item.Persist.ToString();
                    long fileTime = ((long)item.LastWrittenHigh << 32) | item.LastWrittenLow;
                    entry.LastWritten = DateTime.FromFileTime(fileTime);
                    // The blob holds the secret for generic credentials. Windows stores these as UTF-16.
                    // Domain-password blobs are not returned in readable form, so their secret comes back empty.
                    if (item.CredentialBlob != IntPtr.Zero && item.CredentialBlobSize > 0)
                    {
                        entry.Secret = Marshal.PtrToStringUni(item.CredentialBlob, (int)(item.CredentialBlobSize / 2));
                    }
                    else { entry.Secret = ""; }
                    list.Add(entry);
                }
                return list.ToArray();
            }
            finally { CredFree(buffer); }
        }

        public static void Restore(string target, uint type, string userName, uint persist, string secret)
        {
            CREDENTIAL cred = new CREDENTIAL();
            cred.Type = type;
            cred.TargetName = target;
            cred.UserName = userName;
            cred.Persist = persist;
            byte[] blob = string.IsNullOrEmpty(secret)
                ? new byte[0] : System.Text.Encoding.Unicode.GetBytes(secret);
            IntPtr blobPointer = Marshal.AllocHGlobal(blob.Length);
            try
            {
                Marshal.Copy(blob, 0, blobPointer, blob.Length);
                cred.CredentialBlob = blobPointer;
                cred.CredentialBlobSize = (uint)blob.Length;
                if (!CredWrite(ref cred, 0)) { throw new Win32Exception(Marshal.GetLastWin32Error()); }
            }
            finally { Marshal.FreeHGlobal(blobPointer); }
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
    param (
        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [scriptblock]$Action
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
        Write-Log "Failed: $Description. $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Add-Warning {
    param ([Parameter(Mandatory)] [string]$Message)
    Write-Log $Message -Level WARNING
    $script:warnings.Add($Message)
}

function Get-OneDrivePath {
    # Business accounts only. $env:OneDrive can point at a personal OneDrive, which is not where company
    # data should go.
    $candidates = @($env:OneDriveCommercial)
    $account = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive\Accounts\Business1' -ErrorAction Ignore
    if ($account) { $candidates += $account.UserFolder }
    $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -First 1
}

function Get-SessionProcess {
    param ([Parameter(Mandatory)] [string]$Name)
    $sessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
    @(Get-Process -Name $Name -ErrorAction Ignore | Where-Object { $_.SessionId -eq $sessionId })
}

function Close-UserApp {
    # Returns $true when the app is not running (or was closed), $false when it is still open.
    param ([Parameter(Mandatory)] [string]$ProcessName)

    $running = Get-SessionProcess -Name $ProcessName
    if ($running.Count -eq 0) { return $true }
    if (-not $CloseApps) { return $false }

    Invoke-Action -Description "Close $ProcessName ($($running.Count) processes)" -Action {
        # Ask nicely first so browsers save their session, then force whatever is left.
        foreach ($process in $running) { $null = $process.CloseMainWindow() }
        $deadline = (Get-Date).AddSeconds(15)
        while ((Get-Date) -lt $deadline -and (Get-SessionProcess -Name $ProcessName).Count -gt 0) {
            Start-Sleep -Milliseconds 500
        }
        Get-SessionProcess -Name $ProcessName | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    return ($script:DryRun -or (Get-SessionProcess -Name $ProcessName).Count -eq 0)
}

#endregion

#region Main Functions

function Backup-Folder {
    # Streams files into a zip built in %TEMP%. Each file is read in full before its zip entry is created:
    # browsers hold byte-range locks on some databases, a read can fail halfway, and a half-written zip entry
    # cannot be taken back. Unreadable files are counted as skipped instead of failing the whole item.
    param (
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination,

        [string[]]$Skip = @()
    )

    $skipSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in $Skip) { $null = $skipSet.Add($name) }
    # Lock files exist only while the app runs and are always held open.
    $lockFiles = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in @('LOCK', 'lockfile', 'SingletonLock', 'SingletonCookie', 'SingletonSocket', 'parent.lock',
            '.parentlock')) { $null = $lockFiles.Add($name) }

    $stats = @{ Files = 0; Bytes = [long]0; Skipped = 0 }
    $tempZip = Join-Path $env:TEMP ('pm-{0}.zip' -f [guid]::NewGuid().ToString('N'))
    $rootLength = $Source.TrimEnd('\', '/').Length + 1
    $bufferLimit = 64MB
    $minDate = New-Object DateTime 1980, 1, 2
    $maxDate = New-Object DateTime 2107, 12, 30

    try {
        $zip = [System.IO.Compression.ZipFile]::Open($tempZip, [System.IO.Compression.ZipArchiveMode]::Create)
        try {
            $stack = New-Object 'System.Collections.Generic.Stack[System.IO.DirectoryInfo]'
            $stack.Push((New-Object System.IO.DirectoryInfo $Source))
            while ($stack.Count -gt 0) {
                $directory = $stack.Pop()
                try { $entries = $directory.GetFileSystemInfos() }
                catch { $stats.Skipped++; continue }

                foreach ($entry in $entries) {
                    $relative = $entry.FullName.Substring($rootLength).Replace('\', '/')
                    if ($entry -is [System.IO.DirectoryInfo]) {
                        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
                        # Cache names are only skipped outside extension folders, where an extension's own
                        # "cache" folder would make the browser flag it as corrupted.
                        $insideExtension = $relative -match '(^|/)(Extensions|Local Extension Settings)/'
                        if ($skipSet.Contains($entry.Name) -and -not $insideExtension) { continue }
                        $stack.Push($entry)
                        continue
                    }
                    if ($lockFiles.Contains($entry.Name)) { continue }

                    $buffer = $null
                    try {
                        $reader = [System.IO.File]::Open($entry.FullName, 'Open', 'Read', 'ReadWrite')
                        try {
                            if ($reader.Length -le $bufferLimit) {
                                $buffer = New-Object System.IO.MemoryStream
                            }
                            else {
                                $spill = Join-Path $env:TEMP ('pm-{0}.tmp' -f [guid]::NewGuid().ToString('N'))
                                $buffer = [System.IO.File]::Create($spill, 81920, 'DeleteOnClose')
                            }
                            $reader.CopyTo($buffer)
                            $buffer.Position = 0
                        }
                        finally {
                            $reader.Dispose()
                        }
                    }
                    catch {
                        if ($buffer) { $buffer.Dispose() }
                        $stats.Skipped++
                        Write-Log "Skipped $relative. $($_.Exception.Message)" -Level DEBUG
                        continue
                    }

                    try {
                        $zipEntry = $zip.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
                        if ($entry.LastWriteTime -gt $minDate -and $entry.LastWriteTime -lt $maxDate) {
                            $zipEntry.LastWriteTime = $entry.LastWriteTime
                        }
                        $writer = $zipEntry.Open()
                        try { $buffer.CopyTo($writer) } finally { $writer.Dispose() }
                        $stats.Files++
                        $stats.Bytes += $buffer.Length
                    }
                    finally {
                        $buffer.Dispose()
                    }
                }
            }
        }
        finally {
            $zip.Dispose()
        }
        Move-Item -LiteralPath $tempZip -Destination $Destination -Force
    }
    catch {
        Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
        throw
    }
    return $stats
}

function Restore-Folder {
    param (
        [Parameter(Mandatory)]
        [string]$ZipPath,

        [Parameter(Mandatory)]
        [string]$Target
    )

    $aside = $null
    if (Test-Path -LiteralPath $Target) {
        $aside = '{0}.pre-restore-{1:yyyyMMdd-HHmmss}' -f $Target, (Get-Date)
        Invoke-Action -Description "Move the current $Target aside to $aside" -Action {
            Rename-Item -LiteralPath $Target -NewName (Split-Path -Path $aside -Leaf)
        }
    }
    try {
        Invoke-Action -Description "Extract $ZipPath to $Target" -Action {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $Target)
        }
    }
    catch {
        if ($aside -and -not $script:DryRun) {
            Write-Log "Putting the original $Target back" -Level WARNING
            try {
                if (Test-Path -LiteralPath $Target) { Remove-Item -LiteralPath $Target -Recurse -Force }
                Rename-Item -LiteralPath $aside -NewName (Split-Path -Path $Target -Leaf)
            }
            catch {
                Write-Log "Could not put it back ($($_.Exception.Message)). The original is at $aside." -Level ERROR
            }
        }
        throw
    }
}

function Export-SavedLogin {
    param ([Parameter(Mandatory)] [string]$Destination)

    if (-not ('ProfileMigration.CredentialList' -as [type])) {
        Add-Type -TypeDefinition $credentialSource -Language CSharp
    }
    $all = @([ProfileMigration.CredentialList]::Get())
    $keep = @($all | Where-Object { $_.Persist -ne 'Session' -and $_.Target -notmatch $credentialNoise } |
        Sort-Object Target |
        Select-Object Target, Type, TypeCode, UserName, Persist, PersistCode, Secret,
        @{ Name = 'LastWritten'; Expression = { $_.LastWritten.ToString('yyyy-MM-dd') } })
    Write-Log "Credential Manager: $($all.Count) entries, $($keep.Count) backed up for restore after the move"

    # This file holds the stored secrets in clear text. It is written into the backup folder alongside the
    # profile data and travels with it, the same as the original tool did.
    Invoke-Action -Description "Save the credential backup to $Destination" -Action {
        if ($keep.Count -gt 0) { $keep | Export-Csv -Path $Destination -NoTypeInformation -Encoding UTF8 }
        else {
            Set-Content -Path $Destination `
                -Value '"Target","Type","TypeCode","UserName","Persist","PersistCode","Secret","LastWritten"'
        }
    }
    [ordered]@{ Name = 'SavedLogins'; File = 'SavedLogins.csv'; Files = $keep.Count; Bytes = 0; Skipped = 0 }
}

function Restore-SavedLogin {
    param ([Parameter(Mandatory)] [string]$Source)

    if (-not ('ProfileMigration.CredentialList' -as [type])) {
        Add-Type -TypeDefinition $credentialSource -Language CSharp
    }
    $entries = @(Import-Csv -Path $Source)
    if ($entries.Count -eq 0) {
        Write-Log 'The credential backup is empty'
        return
    }
    $written = 0
    foreach ($entry in $entries) {
        if (-not $entry.Target) { continue }
        Invoke-Action -Description "Restore credential $($entry.Target)" -Action {
            [ProfileMigration.CredentialList]::Restore($entry.Target, [uint32]$entry.TypeCode, $entry.UserName,
                [uint32]$entry.PersistCode, $entry.Secret)
        }
        $written++
    }
    Write-Log "Restored $written credentials into Credential Manager" -Level SUCCESS
}

function Resolve-BackupTarget {
    if ($BackupPath) { return $BackupPath }
    if ($Storage -eq 'Local') { return (Join-Path $LocalRoot $setName) }

    $oneDrive = Get-OneDrivePath
    if (-not $oneDrive) {
        $script:exitCode = 30
        throw 'OneDrive for Business is not set up for this user. Sign in to OneDrive or use -Storage Local.'
    }
    if ((Get-SessionProcess -Name 'OneDrive').Count -eq 0) {
        Add-Warning 'OneDrive is not running, so the backup will not upload until it starts.'
    }
    Join-Path (Join-Path $oneDrive $backupFolderName) $setName
}

function Find-BackupSet {
    if ($BackupPath) {
        $folders = @($BackupPath)
    }
    else {
        $roots = @()
        if ($Storage -eq 'Local') {
            $roots += $LocalRoot
        }
        else {
            $current = Get-OneDrivePath
            if ($current) { $roots += Join-Path $current $backupFolderName }
            # After the move, the old "OneDrive - OldCo" folder often still sits in the profile with the backup.
            $oldOneDrives = Get-ChildItem -LiteralPath $env:USERPROFILE -Directory -Filter 'OneDrive*' -Force `
                -ErrorAction Ignore
            $roots += @($oldOneDrives | ForEach-Object { Join-Path $_.FullName $backupFolderName })
        }
        $roots = @($roots | Select-Object -Unique)
        Write-Log "Looking for backups in: $($roots -join '; ')"
        $folders = @($roots | Where-Object { Test-Path -LiteralPath $_ } |
            ForEach-Object { Get-ChildItem -LiteralPath $_ -Directory | Select-Object -ExpandProperty FullName })
    }

    $sets = @(foreach ($folder in $folders) {
        $manifestPath = Join-Path $folder 'manifest.json'
        if (-not (Test-Path -LiteralPath $manifestPath)) { continue }
        try {
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            [pscustomobject]@{
                Path     = $folder
                Name     = Split-Path -Path $folder -Leaf
                Created  = [datetime]$manifest.Created
                Manifest = $manifest
            }
        }
        catch {
            Add-Warning "Could not read $manifestPath. $($_.Exception.Message)"
        }
    })

    if ($sets.Count -eq 0) {
        $script:exitCode = 30
        throw 'No backup found. If it is still syncing down, wait for OneDrive, or pass -BackupPath.'
    }
    $pick = $sets | Where-Object { $_.Name -eq $setName } | Sort-Object Created -Descending |
        Select-Object -First 1
    if (-not $pick) {
        # Names can change in a tenant move (new UPN, device renamed by the provisioning package). A user's
        # own OneDrive only holds that user's backups, so the newest one is the right one there.
        if ($Storage -eq 'OneDrive' -or $sets.Count -eq 1) {
            $pick = $sets | Sort-Object Created -Descending | Select-Object -First 1
            if ($sets.Count -gt 1) {
                Add-Warning "No backup named $setName. Using the newest, $($pick.Name). -BackupPath picks another."
            }
        }
        else {
            $script:exitCode = 2
            throw "Several backups in $LocalRoot and none is named $setName. Pass -BackupPath with one of: " +
                ($sets.Name -join ', ')
        }
    }
    Write-Log ('Restoring from {0} (made {1:yyyy-MM-dd HH:mm} by {2} on {3})' -f $pick.Path, $pick.Created,
        $pick.Manifest.UserName, $pick.Manifest.ComputerName)
    return $pick
}

function Set-EdgeForceSync {
    # Turn on the Edge ForceSync policy so Edge signs in and syncs favorites, passwords, and settings from the
    # user's account after the move. This is set at backup time so the policy is already in place at migration.
    $edgeRegPath = 'HKCU:\SOFTWARE\Policies\Microsoft\Edge'
    Invoke-Action -Description 'Set Edge ForceSync policy (HKCU) to 1' -Action {
        if (-not (Test-Path -Path $edgeRegPath)) { $null = New-Item -Path $edgeRegPath -Force }
        $null = New-ItemProperty -Path $edgeRegPath -Name 'ForceSync' -Value 1 -PropertyType DWord -Force
    }
}

function Invoke-BackupMode {
    $target = Resolve-BackupTarget
    Write-Log "Backup folder: $target"
    Invoke-Action -Description "Create $target" -Action {
        $null = New-Item -Path $target -ItemType Directory -Force
    }
    $script:backupTarget = $target

    Set-EdgeForceSync

    # Keep entries from an earlier run for items this run does not touch.
    $manifestPath = Join-Path $target 'manifest.json'
    $results = @{}
    if (Test-Path -LiteralPath $manifestPath) {
        try {
            foreach ($old in (Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json).Items) {
                $results[$old.Name] = $old
            }
        }
        catch {
            Add-Warning "Existing manifest.json could not be read and will be replaced. $($_.Exception.Message)"
        }
    }

    foreach ($name in $Item) {
        if ($name -eq 'SavedLogins') {
            try { $results[$name] = Export-SavedLogin -Destination (Join-Path $target 'SavedLogins.csv') }
            catch { Add-Warning "SavedLogins failed. $($_.Exception.Message)" }
            continue
        }

        $definition = $catalog[$name]
        $source = [Environment]::ExpandEnvironmentVariables($definition.Path)
        if (-not (Test-Path -LiteralPath $source -PathType Container)) {
            Write-Log "${name}: nothing at $source, skipping"
            continue
        }
        if ($definition.Process -and -not (Close-UserApp -ProcessName $definition.Process)) {
            Add-Warning "$name is open, so files it is writing may be copied mid-write. -CloseApps avoids that."
        }

        $zipPath = Join-Path $target "$name.zip"
        if ($script:DryRun) {
            Write-Log "[DRYRUN] Would zip $source to $zipPath"
            continue
        }
        try {
            Write-Log "${name}: zipping $source"
            $stats = Backup-Folder -Source $source -Destination $zipPath -Skip $definition.Skip
            Write-Log ('{0}: {1} files, {2:N1} MB' -f $name, $stats.Files, ($stats.Bytes / 1MB)) -Level SUCCESS
            if ($stats.Skipped -gt 0) {
                Add-Warning "${name}: $($stats.Skipped) files or folders could not be read (DEBUG lines in the log)"
            }
            $results[$name] = [ordered]@{
                Name    = $name
                File    = "$name.zip"
                Files   = $stats.Files
                Bytes   = $stats.Bytes
                Skipped = $stats.Skipped
            }
        }
        catch {
            Add-Warning "$name backup failed. $($_.Exception.Message)"
        }
    }

    $manifest = [ordered]@{
        ScriptVersion = $scriptVersion
        Created       = (Get-Date).ToString('o')
        ComputerName  = $env:COMPUTERNAME
        UserName      = '{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME
        UserSid       = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        Items         = @($results.Values)
    }
    Invoke-Action -Description "Write $manifestPath" -Action {
        $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    }
    if ($Storage -eq 'OneDrive' -and -not $BackupPath) {
        Write-Log 'OneDrive uploads the backup in the background. Wait for it to show as synced before migrating.'
    }
}

function Invoke-RestoreMode {
    $set = Find-BackupSet
    $available = @($set.Manifest.Items | ForEach-Object { $_.Name })
    $restored = @()

    foreach ($name in $Item) {
        if ($available -notcontains $name) {
            Write-Log "${name}: not in this backup, skipping"
            continue
        }
        if ($name -eq 'SavedLogins') {
            try { Restore-SavedLogin -Source (Join-Path $set.Path 'SavedLogins.csv') }
            catch { Add-Warning "SavedLogins restore failed. $($_.Exception.Message)" }
            continue
        }

        $definition = $catalog[$name]
        $target = [Environment]::ExpandEnvironmentVariables($definition.Path)
        $zipPath = Join-Path $set.Path "$name.zip"
        if (-not (Test-Path -LiteralPath $zipPath)) {
            Add-Warning "${name}: $zipPath is missing"
            continue
        }
        if ($definition.RequireParent -and -not (Test-Path -LiteralPath (Split-Path -Path $target -Parent))) {
            Add-Warning "${name}: not set up for this account yet. Open the app once, close it, then run this again."
            continue
        }
        if ($definition.Process -and -not (Close-UserApp -ProcessName $definition.Process)) {
            Add-Warning "${name}: skipped because it is open and would undo the restore. Close it or use -CloseApps."
            continue
        }
        try {
            Restore-Folder -ZipPath $zipPath -Target $target
            Write-Log "${name}: restored" -Level SUCCESS
            $restored += $name
        }
        catch {
            Add-Warning "${name}: restore failed. $($_.Exception.Message)"
        }
    }

    if ($restored -contains 'Chrome' -or $restored -contains 'Edge') {
        Write-Log ('Bookmarks, history, and extensions are back. Saved passwords and cookies were encrypted ' +
            'to the old account and will not open, so users need to sign in to sites again.') -Level WARNING
    }
}

#endregion

#region Script Body

try {
    $null = New-Item -Path (Split-Path -Path $script:LogPath -Parent) -ItemType Directory -Force
    Write-Log ('invoke-user-data-transfer.ps1 {0} | Mode={1} | Storage={2} | {3}\{4} on {5}' -f $scriptVersion, $Mode,
        $Storage, $env:USERDOMAIN, $env:USERNAME, $env:COMPUTERNAME)
    Write-Log "Items: $($Item -join ', ') | CloseApps=$CloseApps"
    if ($script:DryRun) { Write-Log '*** DRY RUN: nothing will be changed ***' -Level WARNING }

    if ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value -eq 'S-1-5-18') {
        $script:exitCode = 20
        throw 'This runs as the signed-in user, not SYSTEM. In the RMM, pick "run as logged-on user".'
    }
    Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

    switch ($Mode) {
        'Backup'  { Invoke-BackupMode }
        'Restore' { Invoke-RestoreMode }
    }

    if ($script:exitCode -eq 0 -and $script:warnings.Count -gt 0) { $script:exitCode = 50 }
    if ($script:exitCode -eq 0) { Write-Log "$Mode finished" -Level SUCCESS }
    else { Write-Log "$Mode finished with $($script:warnings.Count) warnings" -Level WARNING }
}
catch {
    Write-Log "Stopped: $($_.Exception.Message)" -Level ERROR
    Write-Log "At: $($_.ScriptStackTrace)" -Level DEBUG
    if ($script:exitCode -eq 0) { $script:exitCode = 1 }
}
finally {
    Write-Log ('Duration {0:hh\:mm\:ss}. Log: {1}' -f ((Get-Date) - $scriptStart), $script:LogPath)
    # Keep a copy of the backup log next to the backup, so it is visible from OneDrive on the web too.
    if ($script:backupTarget -and -not $script:DryRun -and (Test-Path -LiteralPath $script:backupTarget)) {
        $logCopy = Join-Path $script:backupTarget 'backup-log.txt'
        Copy-Item -LiteralPath $script:LogPath -Destination $logCopy -Force -ErrorAction SilentlyContinue
    }
}

exit $script:exitCode

#endregion
