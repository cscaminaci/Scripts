# Get all users
$users = Get-HaloUser

$filteredItems = $users | Where-Object { $_.isserviceaccount -eq $true }

$batchItems = @()

# Iterate through each user
foreach ($i in $filteredItems) {
    # Check if isserviceaccount exists
    if ($i.isserviceaccount -ne $false) {
        $i.isserviceaccount = $false
    }
    else {
        $i | Add-Member -NotePropertyName isserviceaccount -NotePropertyValue $true
    }

    # Add modified user object to batch array
    $batchItems += $i

    # Check if batch array contains 50 items
    if ($batchItems.Count -eq 50) {
        # Send batch request
        Set-HaloUser $batchItems

        # Clear batch array
        $batchItems = @()

        # Pause for 5 seconds to ensure no more than 1 request per 5 seconds
        Start-Sleep -Seconds 5
    }
}

# Check if there are any remaining user objects in the batch array
if ($batchItems.Count -gt 0) {
    # Send final batch request for remaining user objects
    Set-HaloUser $batchItems
}
