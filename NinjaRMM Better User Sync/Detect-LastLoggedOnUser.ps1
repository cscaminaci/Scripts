# Function to set Ninja custom field
function Set-NinjaCustomField {
    param (
        [string]$fieldName,
        [string]$fieldValue
    )

    try {
        & ninja-property-set $fieldName $fieldValue
    } catch {
        throw "Failed to set Ninja custom field: $_"
    }
}

# Function to get email UPN from Outlook OST file
function Get-UPNFromOST {
    param (
        [string]$userProfilePath
    )

    $outlookVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -ErrorAction SilentlyContinue).VersionToReport
    if (-not $outlookVersion) {
        $outlookVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Office\16.0\Outlook\InstallRoot" -ErrorAction SilentlyContinue).Path
    }
    
    if (-not $outlookVersion) {
        throw "Outlook installation not found"
    }

    $ostPath = Join-Path $userProfilePath "AppData\Local\Microsoft\Outlook"
    $ostFiles = Get-ChildItem -Path $ostPath -Filter "*.ost" -ErrorAction SilentlyContinue

    if (-not $ostFiles) {
        throw "No Outlook OST files found"
    }

    $freeEmailDomains = @("gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "aol.com", "icloud.com")
    $validOsts = @()

    foreach ($ost in $ostFiles) {
        if ($ost.Name -match '.*?([^\s_]+@[^\s]+)') {
            $upn = $Matches[1] -replace '\.ost$', ''
            $domain = $upn.Split('@')[1]
            if ($freeEmailDomains -notcontains $domain) {
                $validOsts += [PSCustomObject]@{
                    UPN = $upn
                    LastWriteTime = $ost.LastWriteTime
                }
            }
        }
    }

    if ($validOsts.Count -eq 0) {
        throw "No valid company UPN found in OST files"
    }

    return $validOsts | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

# Function to get all user profiles
function Get-UserProfiles {
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $_.Name -ne "Public" -and $_.Name -ne "Default" }
    return $userProfiles
}

# Main script execution
try {
    Write-Output "Script started. Attempting to find user profiles..."

    $userProfiles = Get-UserProfiles
    if ($userProfiles.Count -eq 0) {
        throw "No user profiles found in C:\Users"
    }

    Write-Output "Found $($userProfiles.Count) user profile(s)."

    $validProfiles = @()

    foreach ($profile in $userProfiles) {
        $userProfilePath = $profile.FullName
        $userName = $profile.Name

        Write-Output "Checking profile: $userName"

        try {
            $upnInfo = Get-UPNFromOST -userProfilePath $userProfilePath
            $validProfiles += [PSCustomObject]@{
                UserName = $userName
                UPN = $upnInfo.UPN
                LastWriteTime = $upnInfo.LastWriteTime
                ProfileLastWriteTime = $profile.LastWriteTime
            }
            Write-Output "Successfully detected UPN for $userName : $($upnInfo.UPN)"
        } catch {
            Write-Output "Failed to process profile $userName : $_"
        }
    }

    if ($validProfiles.Count -eq 0) {
        throw "No valid UPN found in any user profile"
    }

    # Sort profiles by OST last write time, then by profile folder last write time
    $mostRecentProfile = $validProfiles | Sort-Object -Property LastWriteTime, ProfileLastWriteTime -Descending | Select-Object -First 1

    Write-Output "Most recent active profile: $($mostRecentProfile.UserName) with UPN: $($mostRecentProfile.UPN)"

    # Set the Ninja custom field
    Set-NinjaCustomField -fieldName "lastDetectedUser" -fieldValue $mostRecentProfile.UPN

    Write-Output "Successfully set lastDetectedUser to $($mostRecentProfile.UPN)"
} catch {
    $errorMessage = $_.Exception.Message
    Write-Output "Error: $errorMessage"
    # Exit gracefully without updating any fields
    exit 0
}