#Requires -Version 5.1
<#
.SYNOPSIS
    Inventories a Windows device and its user profiles before an Entra ID tenant-to-tenant migration.

.DESCRIPTION
    Run as SYSTEM (or an elevated admin) on each device. Writes one CSV row per user profile with the
    device details repeated on every row, so the files from every device merge into one sheet:

      Device:  name, serial, make, model, OS and build, join type, tenant, MDM provider, BitLocker,
               free space on the system drive.
      Profile: account, account type (Entra, domain, local), SID, path, loaded, last used, size on disk,
               Chrome/Edge data size, Firefox and Sticky Notes present, PST/OST count and size,
               OneDrive folders.

    Sizes count only what is on disk. OneDrive files that are cloud-only are skipped, and so are
    junctions, so a profile is never counted twice.

    If a container SAS URL is available the CSV is uploaded to that container with one PUT request,
    so azcopy is not needed. See the README for the one-liner that merges every device's CSV.

    Windows only. Targets Windows PowerShell 5.1.

.PARAMETER SasUrl
    Blob container SAS URL with Create and Write permission. Defaults to the SasUrl environment variable
    (an RMM script variable). Leave empty to keep the report on the device only.

.PARAMETER OutputDirectory
    Where the CSV is saved on the device. Default: C:\ProfileMigration\Inventory.

.PARAMETER SkipSizeScan
    Skip the folder size scan. Much faster on large profiles; size columns stay empty.

.PARAMETER Verbosity
    Console detail: Low, Medium, or High. The log file always gets everything. Default: High.

.PARAMETER DryRun
    Collects everything and prints it, but does not write the CSV or upload it.

.PARAMETER LogPath
    Log file path. Default: C:\ProfileMigration\Logs\inventory-<timestamp>.log.

.EXAMPLE
    .\get-migration-inventory.ps1 -DryRun
    Prints the inventory without saving or uploading it.

.EXAMPLE
    .\get-migration-inventory.ps1 -SasUrl 'https://acct.blob.core.windows.net/inventory?sv=...&sp=cw&sig=...'
    Saves the CSV locally and uploads it to the inventory container.

.NOTES
    Author:     Christopher Scaminaci
    Version:    2.0.0
    Updated:    2026-09-22
    AI Assist:  Refactored with Claude (Anthropic)
    Requires:   SYSTEM or elevated admin (needs to read every profile).
    Exit codes: 0 success, 1 unexpected error, 2 bad SAS URL, 10 upload failed, 20 not elevated.
    Provided as-is with no warranty.
#>

[CmdletBinding()]
param (
    [string]$SasUrl = $env:SasUrl,

    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = 'C:\ProfileMigration\Inventory',

    [switch]$SkipSizeScan,

    [ValidateSet('Low', 'Medium', 'High')]
    [string]$Verbosity = 'High',

    [switch]$DryRun,

    [string]$LogPath
)

#region Configuration & Constants

function ConvertTo-CommandLineArgument {
    # Quotes one argument by the Windows command-line rules. Windows PowerShell 5.1 does not do this itself.
    param ([AllowEmptyString()] [string]$Value)
    if ($Value -and $Value -notmatch '[\s"]') { return $Value }
    $escaped = ($Value -replace '(\\*)"', '$1$1\"') -replace '(\\+)$', '$1$1'
    '"{0}"' -f $escaped
}

# A 32-bit agent gets a redirected HKLM\SOFTWARE, no dsregcmd.exe, and no BitLocker module. Hop to 64-bit.
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $nativePowerShell = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\powershell.exe'
    $relaunchArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
        (ConvertTo-CommandLineArgument $PSCommandPath))
    foreach ($bound in $PSBoundParameters.GetEnumerator()) {
        if ($bound.Value -is [switch]) {
            if ($bound.Value) { $relaunchArgs += "-$($bound.Key)" }
        }
        elseif ("$($bound.Value)" -eq '') {
            # "-Name:" with nothing after it would swallow the next argument.
            $relaunchArgs += "-$($bound.Key)"
            $relaunchArgs += '""'
        }
        else {
            $relaunchArgs += '-{0}:{1}' -f $bound.Key, (ConvertTo-CommandLineArgument "$($bound.Value)")
        }
    }
    $child = Start-Process -FilePath $nativePowerShell -ArgumentList ($relaunchArgs -join ' ') -NoNewWindow -PassThru
    $null = $child.Handle
    $child.WaitForExit()
    exit $child.ExitCode
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$scriptVersion = '2.0.0'
$scriptStart = Get-Date
$script:Verbosity = $Verbosity
$script:DryRun = [bool]$DryRun
$script:exitCode = 0

if (-not $LogPath) {
    $LogPath = Join-Path 'C:\ProfileMigration\Logs' ('inventory-{0:yyyyMMdd-HHmmss}.log' -f $scriptStart)
}
$script:LogPath = $LogPath

# Cloud-only OneDrive files carry OFFLINE (0x1000) or RECALL_ON_DATA_ACCESS (0x400000) and use no disk.
$cloudOnlyMask = 0x401000

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

function Initialize-Directory {
    # Folders under C:\ inherit "Authenticated Users: Modify", and the CSV lists every account on the device.
    # A folder this script creates is locked to SYSTEM and Administrators. An existing folder is left as it is,
    # so pointing -OutputDirectory at a shared folder never rewrites that folder's permissions.
    param ([Parameter(Mandatory)] [string]$Path)
    if (Test-Path -LiteralPath $Path) { return }
    $null = New-Item -Path $Path -ItemType Directory -Force
    $ErrorActionPreference = 'Continue'
    $null = & icacls.exe $Path /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' /Q 2>&1
}

function Hide-SasToken {
    param ([string]$Text)
    if (-not $Text) { return '' }
    $Text -replace '(?i)(sig=)[^&]+', '$1***'
}

function Measure-Folder {
    # Walks a folder once. Skips junctions and symlinks (profiles are full of legacy ones) and counts only
    # files that take up disk space. Optionally tallies PST and OST files found along the way.
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$CountOutlookFiles
    )

    $stats = @{ Bytes = [long]0; PstCount = 0; PstBytes = [long]0; OstCount = 0; OstBytes = [long]0 }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $stats }

    $stack = New-Object 'System.Collections.Generic.Stack[System.IO.DirectoryInfo]'
    $stack.Push((New-Object System.IO.DirectoryInfo $Path))
    while ($stack.Count -gt 0) {
        $directory = $stack.Pop()
        try { $entries = $directory.GetFileSystemInfos() } catch { continue }
        foreach ($entry in $entries) {
            if ($entry -is [System.IO.DirectoryInfo]) {
                # OneDrive folders are reparse points too, so only real links are skipped. If the link type
                # cannot be read, skip the folder rather than risk walking in a loop.
                $isLink = $false
                if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                    try { $isLink = $entry.LinkType -in 'Junction', 'SymbolicLink' } catch { $isLink = $true }
                }
                if (-not $isLink) { $stack.Push($entry) }
                continue
            }
            if ([int]$entry.Attributes -band $cloudOnlyMask) { continue }
            $stats.Bytes += $entry.Length
            if ($CountOutlookFiles) {
                switch ($entry.Extension) {
                    '.pst' { $stats.PstCount++; $stats.PstBytes += $entry.Length }
                    '.ost' { $stats.OstCount++; $stats.OstBytes += $entry.Length }
                }
            }
        }
    }
    return $stats
}

function Get-JoinState {
    $result = [ordered]@{ AzureAdJoined = 'NO'; DomainJoined = 'NO'; TenantName = ''; TenantId = '' }
    $ErrorActionPreference = 'Continue'
    $output = & (Join-Path $env:WINDIR 'System32\dsregcmd.exe') /status 2>&1 | ForEach-Object { "$_" }
    foreach ($line in $output) {
        if ($line -match '^\s*(AzureAdJoined|DomainJoined|TenantName|TenantId)\s*:\s*(.*?)\s*$') {
            $result[$Matches[1]] = $Matches[2]
        }
    }
    [pscustomobject]$result
}

#endregion

#region Main Functions

function Get-DeviceInfo {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = '$env:SystemDrive'"
    $release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
    $join = Get-JoinState

    $joinType = if ($join.AzureAdJoined -eq 'YES' -and $join.DomainJoined -eq 'YES') { 'Hybrid' }
    elseif ($join.AzureAdJoined -eq 'YES') { 'Entra' }
    elseif ($join.DomainJoined -eq 'YES') { 'Domain' }
    else { 'Workgroup' }

    $mdm = @(Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Enrollments' -ErrorAction SilentlyContinue |
        ForEach-Object { $_.GetValue('ProviderID') } | Where-Object { $_ } | Sort-Object -Unique) -join '; '

    $bitLocker = 'Unknown'
    try {
        $volume = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop
        $bitLocker = '{0} ({1})' -f $volume.ProtectionStatus, $volume.VolumeStatus
    }
    catch {
        Write-Log "BitLocker status unavailable: $($_.Exception.Message)" -Level DEBUG
    }

    [ordered]@{
        ComputerName = $env:COMPUTERNAME
        SerialNumber = "$($bios.SerialNumber)".Trim()
        Manufacturer = $computer.Manufacturer
        Model        = $computer.Model
        OS           = ('{0} {1}' -f $os.Caption, $release).Trim()
        OSBuild      = $os.Version
        JoinType     = $joinType
        TenantName   = $join.TenantName
        TenantId     = $join.TenantId
        MdmProvider  = $mdm
        BitLocker    = $bitLocker
        FreeSpaceGB  = [math]::Round($disk.FreeSpace / 1GB, 1)
    }
}

function New-ProfileRow {
    # One place defines the profile columns, so every CSV has the same header and merges cleanly.
    [ordered]@{
        ProfileAccount  = ''
        ProfileType     = ''
        ProfileSid      = ''
        ProfilePath     = ''
        ProfileLoaded   = ''
        LastUsed        = ''
        ProfileSizeGB   = ''
        ChromeSizeMB    = ''
        EdgeSizeMB      = ''
        FirefoxProfile  = ''
        StickyNotes     = ''
        PstCount        = ''
        PstSizeMB       = ''
        OstCount        = ''
        OneDriveFolders = ''
    }
}

function Get-ProfileInfo {
    $profiles = @(Get-CimInstance -ClassName Win32_UserProfile -Filter 'Special = FALSE' |
        Where-Object { $_.LocalPath -and (Test-Path -LiteralPath $_.LocalPath) })
    Write-Log "Found $($profiles.Count) user profiles"
    $stickyNotesDb = 'Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite'

    foreach ($userProfile in $profiles) {
        $path = $userProfile.LocalPath
        $sid = $userProfile.SID
        $local = Join-Path $path 'AppData\Local'
        try {
            $account = (New-Object Security.Principal.SecurityIdentifier $sid).Translate(
                [Security.Principal.NTAccount]).Value
        }
        catch {
            $account = "(unresolved) $(Split-Path -Path $path -Leaf)"
        }

        $row = New-ProfileRow
        $row.ProfileAccount = $account
        $row.ProfileType = if ($sid -like 'S-1-12-1-*') { 'Entra' }
        elseif ($account -like "$env:COMPUTERNAME\*") { 'Local' }
        elseif ($sid -like 'S-1-5-21-*') { 'Domain' }
        else { 'Other' }
        $row.ProfileSid = $sid
        $row.ProfilePath = $path
        $row.ProfileLoaded = $userProfile.Loaded

        # NTUSER.DAT is written at sign-out, which makes it a better "last used" than LastUseTime.
        $ntUser = Get-Item -LiteralPath (Join-Path $path 'NTUSER.DAT') -Force -ErrorAction SilentlyContinue
        if ($ntUser) { $row.LastUsed = $ntUser.LastWriteTime.ToString('yyyy-MM-dd HH:mm') }

        $row.FirefoxProfile = Test-Path -LiteralPath (Join-Path $path 'AppData\Roaming\Mozilla\Firefox\profiles.ini')
        $row.StickyNotes = Test-Path -LiteralPath (Join-Path $local $stickyNotesDb)
        $oneDriveDirs = Get-ChildItem -LiteralPath $path -Directory -Filter 'OneDrive*' -Force -ErrorAction Ignore
        $row.OneDriveFolders = @($oneDriveDirs | Select-Object -ExpandProperty Name) -join '; '

        if (-not $SkipSizeScan) {
            Write-Log "Measuring $path"
            $total = Measure-Folder -Path $path -CountOutlookFiles
            $chrome = Measure-Folder -Path (Join-Path $local 'Google\Chrome\User Data')
            $edge = Measure-Folder -Path (Join-Path $local 'Microsoft\Edge\User Data')
            $row.ProfileSizeGB = [math]::Round($total.Bytes / 1GB, 2)
            $row.ChromeSizeMB = [math]::Round($chrome.Bytes / 1MB, 0)
            $row.EdgeSizeMB = [math]::Round($edge.Bytes / 1MB, 0)
            $row.PstCount = $total.PstCount
            $row.PstSizeMB = [math]::Round($total.PstBytes / 1MB, 0)
            $row.OstCount = $total.OstCount
        }
        $row
    }
}

function Send-Inventory {
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $uri = $null
    if (-not [Uri]::TryCreate($SasUrl, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https' -or
        -not $uri.Query) {
        $script:exitCode = 2
        throw 'SasUrl must be an https container URL that includes the SAS token (?sv=...&sig=...).'
    }
    $blobName = [Uri]::EscapeDataString((Split-Path -Path $FilePath -Leaf))
    $blobUrl = '{0}://{1}{2}/{3}{4}' -f $uri.Scheme, $uri.Authority, $uri.AbsolutePath.TrimEnd('/'), $blobName,
        $uri.Query

    Invoke-Action -Description "Upload $blobName to $($uri.Host)$($uri.AbsolutePath)" -Action {
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                $uploadParams = @{
                    Uri             = $blobUrl
                    Method          = 'Put'
                    InFile          = $FilePath
                    ContentType     = 'text/csv'
                    Headers         = @{ 'x-ms-blob-type' = 'BlockBlob' }
                    UseBasicParsing = $true
                    TimeoutSec      = 120
                }
                $null = Invoke-RestMethod @uploadParams
                Write-Log 'Upload complete' -Level SUCCESS
                return
            }
            catch {
                if ($attempt -eq 3) {
                    $script:exitCode = 10
                    throw "Upload failed after 3 attempts: $($_.Exception.Message)"
                }
                Write-Log "Upload attempt $attempt failed: $($_.Exception.Message). Retrying." -Level WARNING
                Start-Sleep -Seconds (5 * $attempt)
            }
        }
    }
}

#endregion

#region Script Body

try {
    Initialize-Directory -Path (Split-Path -Path $script:LogPath -Parent)
    Write-Log "get-migration-inventory.ps1 $scriptVersion | $env:COMPUTERNAME | SizeScan=$(-not $SkipSizeScan)"
    Write-Log "SasUrl: $(if ($SasUrl) { Hide-SasToken $SasUrl } else { 'none, keeping the report local' })"
    if ($script:DryRun) { Write-Log '*** DRY RUN: nothing will be written or uploaded ***' -Level WARNING }

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $script:exitCode = 20
        throw 'Run this as SYSTEM or an elevated admin so every profile can be read.'
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12

    $device = Get-DeviceInfo
    Write-Log ('{0} | {1} {2} | SN {3} | {4} | {5} {6}' -f $device.ComputerName, $device.Manufacturer, $device.Model,
        $device.SerialNumber, $device.OS, $device.JoinType, $device.TenantName)

    $rows = @(Get-ProfileInfo | ForEach-Object {
        $merged = [ordered]@{}
        foreach ($key in $device.Keys) { $merged[$key] = $device[$key] }
        foreach ($key in $_.Keys) { $merged[$key] = $_[$key] }
        $merged.CollectedAt = $scriptStart.ToString('yyyy-MM-dd HH:mm')
        [pscustomobject]$merged
    })
    if ($rows.Count -eq 0) {
        # Keep the device in the merged report even when it has no user profiles.
        $merged = [ordered]@{}
        foreach ($key in $device.Keys) { $merged[$key] = $device[$key] }
        $emptyProfile = New-ProfileRow
        foreach ($key in $emptyProfile.Keys) { $merged[$key] = $emptyProfile[$key] }
        $merged.ProfileAccount = '(no user profiles)'
        $merged.CollectedAt = $scriptStart.ToString('yyyy-MM-dd HH:mm')
        $rows = @([pscustomobject]$merged)
    }

    $safeSerial = $device.SerialNumber -replace '[^A-Za-z0-9_-]', ''
    $fileName = '{0}_{1}_{2:yyyyMMdd-HHmmss}.csv' -f $env:COMPUTERNAME, $safeSerial, $scriptStart
    $csvPath = Join-Path $OutputDirectory $fileName

    if ($script:DryRun) {
        $rows | Format-List | Out-String -Width 200 | ForEach-Object { Write-Host $_ }
    }
    Invoke-Action -Description "Save $csvPath" -Action {
        Initialize-Directory -Path $OutputDirectory
        $rows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    }
    if ($SasUrl) { Send-Inventory -FilePath $csvPath }

    Write-Log "Inventory finished: $($rows.Count) rows" -Level SUCCESS
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
