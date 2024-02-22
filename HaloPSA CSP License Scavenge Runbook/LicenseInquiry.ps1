param ([Parameter (Mandatory = $false)]
	[object]$WebHookData
)

Function Connect_MgGraph
{
	$AppId = "<APP ID FOR HALOCSP>"
	$CertificateName = "<NAME OF CERT IN AUTOMATION ACCOUNT>" 
    $Certificate = Get-AutomationCertificate -Name $CertificateName
	Connect-Graph -TenantId $TenantID -AppId $AppId -Certificate $Certificate
	
}


#Unpack the JSON
$Data = ConvertFrom-Json -InputObject $WebHookData.RequestBody
$HaloUser = $data[0].content.HaloUser
$TicketID = $data[0].content.TicketID
$RequestID = $data[0].id
$Timestamp = $data[0].timestamp
$RefCharacter = $HaloUser.IndexOf("@")
$Global:TenantID = $HaloUser.Substring($RefCharacter + 1)


#Get the Azure context info
try
{
	Connect-AzAccount -Identity
}
catch
{
	Write-Error $_.Exception.Message
}

$Vaultname = "<KEYVAULTNAME>"
$HaloAppID = Get-AzKeyVaultSecret -vaultname $VaultName -Name "HaloAppID" -AsPlainText -EA Stop
$HaloSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "HaloSecret" -AsPlainText -EA Stop
$HaloTenantName = "<HALOTENANTNAME>"
$AgentURL = "https://BASEURLFORHALOPSA"

Connect_MgGraph
if ((Get-MgContext) -ne "")
{
	Write-Host Connected to Microsoft Graph PowerShell using (Get-MgContext).Account account -ForegroundColor Yellow
}

# Get MS license table
$licenseTableURL = "https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv"

# We download the file as a string, convert it to CSV, and select the needed properties
$licenseTable = (Invoke-WebRequest -Uri $LicenseTableURL).ToString() | ConvertFrom-Csv | Select-Object -Property GUID, Product_Display_Name

# Create a hash table of the license names, this is faster to search for the next step
$licenseTableHash = @{ }
$licenseTable | ForEach-Object { $licenseTableHash[$_.GUID] = $_.Product_Display_Name }


$skusHash = @{ } # An empty hashtable
Get-MgSubscribedSku | ForEach-Object {
	# Gets information about all the licenses purchased in the tenant
	# If we have name in the CSV use it, otherwise, use the Part Number
	$DisplayName = if ($licenseTableHash[$_.SkuId]) { $licenseTableHash[$_.SkuId] }
	else { $_.SkuPartNumber }
	# Add the display name as a property to the SKU
	$_ | Add-Member -MemberType NoteProperty -Name DisplayName -Value $DisplayName
	# Update the hash table, hashtable is faster to search by SKU ID than an array.
	$skusHash[$_.SkuId] = $_
}
$LicensePackages = Get-MGSubscribedSku
$SkuData = [System.Collections.Generic.List[Object]]::new()
foreach ($LicensePackage in $LicensePackages)
{
	$LicenseLine = [PSCustomObject][Ordered]@{
		SkuPartNumber  = $LicensePackage.SkuPartNumber
		EnabledUnits   = $LicensePackage.PrepaidUnits.Enabled
		SuspendedUnits = $LicensePackage.PrepaidUnits.Suspended
		WarningUnits   = $LicensePackage.PrepaidUnits.Warning
		ConsumedUnits  = $LicensePackage.ConsumedUnits
		AvailableUnits = $LicensePackage.PrepaidUnits.Enabled - $LicensePackage.ConsumedUnits
	}
	$SkuData.Add($LicenseLine)
}
# Find tenant accounts
Write-Host "Finding zombie accounts..."
[Array]$Users = Get-MgUser -Filter "AccountEnabled eq false" -All | Sort DisplayName
$report = foreach ($user in $users)
{
	if ([string]::IsNullOrWhiteSpace($User.AssignedLicenses) -eq $False)
	{
		#user has license assigned
		foreach ($assignment in $user.AssignedLicenses)
		{
			$assignedLicenseName = $skusHash[$assignment.SkuId].DisplayName
			if (-Not $assignedLicenseName) { continue } # This is a zombie license that is not showing in Azure AD purchased SKUs.
			
			if ($assignment.AssignedByGroup)
			{
				# License is assigned through a group
				$assignmentType = "Group"
				$assignmentGroup = $assignmentGroups[$assignment.AssignedByGroup] # This is why we use hash tables, faster than Where-Object
			}
			else
			{
				# Direct License Assignment
				$assignmentType = "Direct"
				$assignmentGroup = $null
			}
			[PSCustomObject]@{
				UserPrincipalName = $user.UserPrincipalName
				Name			  = $user.DisplayName
				IsLicensed	      = $true
				AssignedLicenseId = $assignment.SkuId
				AssignedLicense   = $assignedLicenseName
				AssignmentType    = $assignmentType
				AssignmentGroup   = $assignmentGroup
			}
		}
	}
	else
	{
		# user does not have any assigned license
		$userHasLicense = $false
		$UnlicensedAccounts++
		<#
		[PSCustomObject]@{
			UserPrincipalName = $user.UserPrincipalName
			Name			  = $user.DisplayName
			IsLicensed	      = $userHasLicense
			UserType		  = $null
			AssignedLicenseId = $null
			AssignedLicense   = $null
			AssignmentType    = $null
			AssignmentGroup   = $null
		}#>
	}
	
}

# Create the HTML report
<#$htmlhead = "<html>
	   <style>
	   BODY{font-family: Arial; font-size: 8pt;}
	   H3{font-size: 12px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
	   TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
	   TD{border: 1px solid #969595; padding: 5px; }
	   td.pass{background: #B7EB83;}
	   td.warn{background: #FFF275;}
	   td.fail{background: #FF2626; color: #ffffff;}
	   td.info{background: #85D4FF;}
	   </style>
	   <body>
           <div align=center>
           <p><h3>Disabled User License Scavenge Report for $TenantID</h3></p><br><br>"
#>
$htmlhead = @"
<html>
<head>
<style>
BODY {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-size: 10pt;
    background: #f4f4f4;
    color: #333;
    margin: 0;
    padding: 20px;
}
H3 {
    font-size: 18px;
    color: #444;
}
TABLE {
    border-collapse: collapse;
    width: 100%;
    margin-top: 20px;
}
TH, TD {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}
TH {
    background-color: #4CAF50;
    color: white;
}
TR:nth-child(even) {
    background-color: #f2f2f2;
}
TR:hover {
    background-color: #ddd;
}
.pass {
    background-color: #B7EB83;
}
.warn {
    background-color: #FFF275;
}
.fail {
    background-color: #FF2626;
    color: white;
}
.info {
    background-color: #85D4FF;
}
.footer {
    text-align: center;
    margin-top: 40px;
    font-size: 9pt;
    color: #666;
}
</style>
</head>
<body>
    <div align="center">
        <h3>Disabled User License Scavenge Report for $TenantID</h3>
"@
$htmlbody1 = $Report | ConvertTo-Html -Fragment
$htmlheader2 = "<br><br><p><h3>Live Snapshot of Azure AD License Status</h3></p><br><br>"
$htmlbody2 = $SkuData | ConvertTo-Html -Fragment
$htmltail = 
"<p>Created: " + (Get-Date) + "<p>" +
"<p>-----------------------------------------------------------------------------------------------------------------------------</p>" +
"<p>Number of licensed disabled user accounts found:    " + $Report.Count + "</p>" +
"<p>Number of unlicensed disabled user accounts found:  " + $UnlicensedAccounts + "</p>" +
"<p>-----------------------------------------------------------------------------------------------------------------------------</p>" +
"</body> </html>"


$htmlreport = $htmlhead + $htmlbody1 + $htmlheader2 + $htmlbody2 + $htmltail
Write-Output "Connecting to HaloPSA"

try
{
	Connect-HaloAPI -ClientID $HaloAppID -Tenant $HaloTenantName -URL $AgentURL -ClientSecret $HaloSecret -Scopes "all"
	Write-Output "Successfully connected to HaloPSA"
}
catch
{
	Write-Output $_.Exception.Message
}

$Body = [PSCustomObject]@{
    "ticket_id" = "$TicketID"
    "outcome" = "Private Note"
    "outcome_id" = 7
    "who_type" = 1
    "who" = "Automation API"
    "who_agentid" = 25
    "hiddenfromuser" = 1
    "note" = "$htmlreport"
}

New-HaloAction -Action $Body 

Disconnect-MgGraph
