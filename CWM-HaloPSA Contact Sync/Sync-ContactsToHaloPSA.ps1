Connect-HaloAPI -ClientID "<<HALO API CLIENT ID>>" -Tenant "<<TENANT>>" -URL "https://<<YOURURL>>.halopsa.com/" -ClientSecret "<<HALO API CLIENT SECRET>>" -Scopes "all"

$headers = @{}
$headers.Add("clientId", "<<CONNECTWISE MANAGE API CLIENT ID>>")
$headers.Add("Accept", "application/vnd.connectwise.com+json; version=2024.1")
$headers.Add("Authorization", "Basic <<AUTH TOKEN HERE>>")

$ClientsToSync = Get-HaloClient
Start-Sleep -Milliseconds 1000
$totalClients = $ClientsToSync.Count
$currentClient = 0

foreach ($Client in $ClientsToSync){
    $currentClient++
    Write-Progress -Activity "Syncing Contacts" -Status "Processing Client $currentClient of $totalClients" -PercentComplete (($currentClient / $totalClients) * 100)
    if($Client.name -match "Unknown"){
        continue
    }
    if($Client.name -match "<<ORG NAME>>"){
        continue
    }
    $Users = Get-HaloUser -ClientID $Client.Id
    Start-Sleep -Milliseconds 1000
    $totalUsers = $Users.Count
    $currentUser = 0

    foreach ($User in $Users){
        $currentUser++
        Write-Progress -Id 1 -Activity "Processing Users" -Status "Processing User $currentUser of $totalUsers" -PercentComplete (($currentUser / $totalUsers) * 100)
        if([string]::IsNullOrEmpty($User.firstname) -or [string]::IsNullOrEmpty($User.surname)) {
            Write-Output "Skipping user due to missing firstname or lastname: $($User.name)"
            continue
        }
    
        $baseUrl = "https://na.myconnectwise.net/v4_6_release/apis/3.0/company/contacts"
        $queryParams = @{
            page = 1
            pageSize = 1000
            conditions = "firstname='$($User.firstname)' and lastname='$($User.surname)'"
        }
    
        $queryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        foreach ($key in $queryParams.Keys) {
            $queryString[$key] = $queryParams[$key]
        }
    
        $uri = "{0}?{1}" -f $baseUrl, $queryString.ToString()
        $CWresponse = Invoke-RestMethod -Uri $uri -Method 'GET' -Headers $headers
        $response = $CWresponse 
        
        if ($response.count -eq 1) {
            if ($response.inactiveflag -eq $true){
                continue
            }
            if ([string]::IsNullOrEmpty($response[0].defaultphonenbr)) {
                Write-Output "Skipping user due to missing defaultphonenbr: $($User.name)"
                continue
            }
            else {
                if ($response[0].defaultphonenbr -ne $User.phonenumber) {
                    $User | Add-Member -NotePropertyName isuserdetails -NotePropertyValue 'true'
                    if ($User.PSObject.Properties.Name -contains "phonenumber"){
                        $User.phonenumber = $response[0].defaultphonenbr
                        #$User.phonenumber_preferred = 0
                    }else{
                        $User | Add-Member -NotePropertyName phonenumber -NotePropertyValue $response[0].defaultphonenbr
                        #$User.phonenumber_preferred = 0
                    }
                    $HaloResult = Set-HaloUser -User $User
                    Start-Sleep -Milliseconds 1000
                    if($HaloResult.phonenumber -match $response[0].defaultPhoneNbr){
                        Write-Output "Successfully updated phone number for $($User.name) - Number set: $($User.phonenumber)"
                    }else{
                        Write-Output "Failed to update phone number for $($User.name)"
                    }
                }
            }
        }
        elseif ($response.count -gt 1) {
            foreach ($result in $response) {
                if ($result.inactiveflag -eq $true){
                    continue
                }
                if ($result.company.name -eq $User.client_name) {
                    if ([string]::IsNullOrEmpty($result.defaultphonenbr)) {
                        Write-Output "Skipping user due to missing defaultphonenbr: $($User.name)"
                        continue
                    }
                    else {
                        if ($result.defaultphonenbr -ne $User.phonenumber) {
                            $User | Add-Member -NotePropertyName isuserdetails -NotePropertyValue 'true'
                            if ($User.PSObject.Properties.Name -contains "phonenumber"){
                                $User.phonenumber = $result.defaultphonenbr
                                #$User.phonenumber_preferred = 0
                            }else{
                                $User | Add-Member -NotePropertyName phonenumber -NotePropertyValue $result.defaultPhoneNbr
                                #$User.phonenumber_preferred = 0
                            }
                            $HaloResult = Set-HaloUser -User $User
                            Start-Sleep -Milliseconds 1000
                            if($HaloResult.phonenumber -match $result.defaultPhoneNbr){
                                Write-Output "Successfully updated phone number for $($User.name) - Number set: $($User.phonenumber)"
                            }else{
                                Write-Output "Failed to update phone number for $($User.name)"
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
}

