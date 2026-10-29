param ([Parameter (Mandatory = $false)]
	[object]$WebHookData
)

$data = ConvertFrom-Json -InputObject $WebHookData.RequestBody

$UserPrincipalName = $data[0].Content.UserPrincipalName
$TicketID = $data[0].Content.TicketID

Import-Module AzureAd
Import-Module ExchangeOnlineManagement

# Get the service principal connection details
$spConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

# Connect AzureAd
Connect-AzureAD -TenantId $spConnection.TenantId -ApplicationId $spConnection.ApplicationID -CertificateThumbprint $spConnection.CertificateThumbprint

# Connect to ExchangeOnline
Connect-ExchangeOnline -CertificateThumbprint $spConnection.CertificateThumbprint -AppId $spConnection.ApplicationID -Organization $tenantName


# Get user ObjectID
$userObjID = Get-AzureAdUser -ObjectId "$UserPrincipalName"


try
{
	Add-MailboxFolderPermission -Identity "$($UserPrincipalName):\Calendar" -User 'user@domain.com' -AccessRights Editor -SharingPermissionFlags none
}
catch
{
	Write-Host $_.Exception.Message
}
