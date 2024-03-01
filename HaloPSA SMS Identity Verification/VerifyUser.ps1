param ([Parameter (Mandatory = $false)]
	[object]$WebHookData
)

Function Connect_MgGraph
{
	$AppId = "<APP ID>"
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
$TenantID = $HaloUser.Substring($RefCharacter + 1)

#Get the Azure context info
try
{
	Connect-AzAccount -Identity
}
catch
{
	Write-Error $_.Exception.Message
}

#Retrieve Keyvault Secrets and set other variables
$random = Get-Random -Minimum 100000 -Maximum 999999
$VaultName = '<kevaultname>'
$sid = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<twiliosid>" -AsPlainText -EA Stop
$token = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<twiliotoken>" -AsPlainText -EA Stop
$DBSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<dbsecret>" -AsPlainText -EA Stop
$AppId = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<appid>" -AsPlainText -EA Stop
$ClientSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<appsecret>" -AsPlainText -EA Stop
$HaloAppId = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<appid>" -AsPlainText -EA Stop
$HaloClientSecret = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<appsecret>" -AsPlainText -EA Stop
$HaloTenantName = "tenantname"
$HaloAgentURL = "https://your.halopsa.url"
$number = "+1XXXXXXXXXX"

#Connect to SQL for logging
$tableName = "dbo.SMSLog"
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "Server=tpskynetdb.database.windows.net;Database=SkynetDB;Uid=techpulse;Pwd=$DBSecret;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
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
$params = @{ To = $MFAPhone; From = $number; Body = "TechPulse Support - Please give this code to your technician to verify your identity: $Random" }

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

Write-Output "Connecting to HaloPSA"

try
{
	Connect-HaloAPI -ClientID $HaloAppID -Tenant $HaloTenantName -URL $HaloAgentURL -ClientSecret $HaloClientSecret -Scopes "edit:tickets"
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
    "note" = "$note"
}

New-HaloAction -Action $Body 

Disconnect-MgGraph


$insertquery = "
		INSERT INTO $tableName
		([RequestID],[Timestamp],[TicketID],[Number],[Code])
			VALUES
				('$RequestID','$Timestamp','$TicketID','$MFAPhone','$Random')"
$Command.CommandText = $insertquery
$Command.ExecuteNonQuery()
$Connection.Close();
