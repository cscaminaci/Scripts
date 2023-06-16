<#	
	.NOTES
	===========================================================================
	 Created on:   	8/27/2022 15:15
	 Created by:   	Ceej - The MSP Automator
	 Organization: 	MSPAutomator.com
	 Filename:     	VerifyUser.ps1
	===========================================================================
	.DESCRIPTION
		Azure Runbook to verify a user identity.
#>


param ([Parameter (Mandatory = $false)]
	[object]$WebHookData
)

Function Connect_MgGraph
{
	$MsalToken = Get-MsalToken -TenantId $TenantId -ClientId $CSPAppId -ClientSecret ($CSPClientSecret | ConvertTo-SecureString -AsPlainText -Force)
	
	#Connect to Graph using access token
	Connect-Graph -AccessToken $MsalToken.AccessToken
	
	Select-MgProfile -Name beta
	
}

Import-Module HaloAPI
Import-Module MSAL.PS
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module SqlServer
Import-Module Az.KeyVault
Import-Module Az.Accounts
Import-Module Az.Automation

#Unpack the JSON
$Data = ConvertFrom-Json -InputObject $WebHookData.RequestBody
$HaloUser = $data[0].content.HaloUser
$TicketID = $data[0].content.TicketID
$RequestID = $data[0].id
$Timestamp = $data[0].timestamp
$RefCharacter = $HaloUser.IndexOf("@")
$TenantID = $HaloUser.Substring($RefCharacter + 1)
$random = Get-Random -Minimum 100000 -Maximum 999999

#Get Azure RunAs information so we can access the keyvault
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

#Connect as Azure RunAs and get the Azure context info
try
{
	Connect-AzAccount `
					  -ServicePrincipal `
					  -Tenant $RunAsConnection.TenantId `
					  -ApplicationId $RunAsConnection.ApplicationId `
					  -CertificateThumbprint $RunAsConnection.CertificateThumbprint | Write-Verbose
	
	Set-AzContext -Subscription $RunAsConnection.SubscriptionID | Write-Verbose
}
catch
{
	Write-Error $_.Exception.Message
}

#VARIABLE DEFINITIONS - CHANGE THESE TO SUIT YOUR ENVIRONMENT
$VaultName = '#############'
#Twilio info
$sid = Get-AzKeyVaultSecret -vaultname $VaultName -Name "###########" -AsPlainText -EA Stop
$token = Get-AzKeyVaultSecret -vaultname $VaultName -Name "##########" -AsPlainText -EA Stop
$FromNumber = "+1##############"
#CSP or your AppID info
$CSPAppId = Get-AzKeyVaultSecret -vaultname $VaultName -Name "###########" -AsPlainText -EA Stop
$CSPClientSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "##########" -AsPlainText -EA Stop
#HaloAPI info
$HaloAppId = Get-AzKeyVaultSecret -vaultname $VaultName -Name "###########" -AsPlainText -EA Stop
$HaloSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "###########" -AsPlainText -EA Stop
$AgentDomain = "HTTPS://YOURAGENTDOMAIN.HALOPSA.COM"
#SQL server info - remove these five lines if not logging to SQL
$SQLServer = "##########.database.windows.net"
$tableName = "dbo.##########"
$DBSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "##########" -AsPlainText -EA Stop
$DBName = "############"
$SQLUser = "############"


#Connect to SQL for logging - remove this block only if you dont want to log to SQL
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "Server=$SQLServer;Database=$DBName;Uid=$SQLUser;Pwd=$DBSecret;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection

Connect_MgGraph
if ((Get-MgContext) -ne "")
{
	Write-Host Connected to Microsoft Graph PowerShell using (Get-MgContext).Account account -ForegroundColor Yellow
}

[array]$MFAData = Get-MgUserAuthenticationMethod -UserId $HaloUser
$AuthenticationMethod = @()
$AdditionalDetails = @()

foreach ($MFA in $MFAData)
{
	Switch ($MFA.AdditionalProperties["@odata.type"])
	{
		"#microsoft.graph.passwordAuthenticationMethod"
		{
			$AuthMethod = 'PasswordAuthentication'
			$AuthMethodDetails = $MFA.AdditionalProperties["displayName"]
		}
		"#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"
		{
			# Microsoft Authenticator App
			$AuthMethod = 'AuthenticatorApp'
			$AuthMethodDetails = $MFA.AdditionalProperties["displayName"]
			$MicrosoftAuthenticatorDevice = $MFA.AdditionalProperties["displayName"]
		}
		"#microsoft.graph.phoneAuthenticationMethod"
		{
			# Phone authentication
			$AuthMethod = 'PhoneAuthentication'
			$AuthMethodDetails = $MFA.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
			$MFAPhone = $MFA.AdditionalProperties["phoneNumber"]
		}
		"#microsoft.graph.fido2AuthenticationMethod"
		{
			# FIDO2 key
			$AuthMethod = 'Fido2'
			$AuthMethodDetails = $MFA.AdditionalProperties["model"]
		}
		"#microsoft.graph.windowsHelloForBusinessAuthenticationMethod"
		{
			# Windows Hello
			$AuthMethod = 'WindowsHelloForBusiness'
			$AuthMethodDetails = $MFA.AdditionalProperties["displayName"]
		}
		"#microsoft.graph.emailAuthenticationMethod"
		{
			# Email Authentication
			$AuthMethod = 'EmailAuthentication'
			$AuthMethodDetails = $MFA.AdditionalProperties["emailAddress"]
		}
		"microsoft.graph.temporaryAccessPassAuthenticationMethod"
		{
			# Temporary Access pass
			$AuthMethod = 'TemporaryAccessPass'
			$AuthMethodDetails = 'Access pass lifetime (minutes): ' + $MFA.AdditionalProperties["lifetimeInMinutes"]
		}
		"#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod"
		{
			# Passwordless
			$AuthMethod = 'PasswordlessMSAuthenticator'
			$AuthMethodDetails = $MFA.AdditionalProperties["displayName"]
		}
		"#microsoft.graph.softwareOathAuthenticationMethod"
		{
			$AuthMethod = 'SoftwareOath'
			$Is3rdPartyAuthenticatorUsed = "True"
		}
		
	}
	$AuthenticationMethod += $AuthMethod
	if ($AuthMethodDetails -ne $null)
	{
		$AdditionalDetails += "$AuthMethod : $AuthMethodDetails"
	}
}
#To remove duplicate authentication methods
$AuthenticationMethod = $AuthenticationMethod | Sort-Object | Get-Unique
$AuthenticationMethods = $AuthenticationMethod -join ","
$AdditionalDetail = $AdditionalDetails -join ", "

# Twilio API endpoint and POST params
$url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
$params = @{ To = $MFAPhone; From = $FromNumber; Body = "Please give this code to your technician to verify your identity: $Random" }

# Create a credential object for HTTP basic auth
$p = $token | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($sid, $p)

# Make API request, selecting JSON properties from response
$TwilioResponse = Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
ConvertFrom-Json | Select sid, body

if ($TwilioResponse -ne $null)
{
	$Note = "VERIFICATION CODE: $Random - Request ID: $RequestID - Timestamp: $Timestamp - TARGET NUMBER: $MFAPhone - Twilio Response: Success - Log Response: Success"
}
else
{
	$Note = "VERIFICATION CODE: $Random - Request ID: $RequestID - Timestamp: $Timestamp - TARGET NUMBER: $MFAPhone - Twilio Response: Failed - Log Response: Failure"
}

$Token = Get-HaloPSAToken -ClientID $HaloAppId -ClientSecret $HaloSecret -AgentDomain $AgentDomain
New-HaloPrivateNote -TicketID $TicketID -Note $Note -Token $Token -AgentDomain $AgentDomain

#REMOVE BELOW HERE IF YOU DONT WANT TO USE SQL LOGGING
$insertquery = "
		INSERT INTO $tableName
		([RequestID],[Timestamp],[TicketID],[Number],[Code])
			VALUES
				('$RequestID','$Timestamp','$TicketID','$MFAPhone','$Random')"
$Command.CommandText = $insertquery
$Command.ExecuteNonQuery()
$Connection.Close();