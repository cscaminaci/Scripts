param ([Parameter (Mandatory = $false)]
	[object]$WebHookData
)
	
Import-Module Az.Accounts
Import-Module Az.automation
Import-Module Az.KeyVault
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Users.Actions


#Unpack the JSON
$Data = ConvertFrom-Json -InputObject $WebHookData.RequestBody
$HaloUser = $data[0].content.HaloUser
$TicketID = $data[0].content.TicketID
$RequestID = $data[0].id
$Timestamp = $data[0].timestamp
$RefCharacter = $HaloUser.IndexOf("@")
$TenantID = $HaloUser.Substring($RefCharacter + 1)

Write-Output "Domain to connect to is $TenantID"
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
$VaultName = '<keyvault name>'
$sid = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<Twilio SID Secret name>" -AsPlainText -EA Stop
$token = Get-AzKeyVaultSecret -vaultname $VaultName -Name "<Twilio token secret name>" -AsPlainText -EA Stop
$WebhookUrl = "<Your webhook URL to Halo>"
$number = "+<your twilio phone number>"

try{

$AppId = "<Your App ID>"
$CertificateName = "<Your certificate name>" 
$Certificate = Get-AutomationCertificate -Name $CertificateName

# Ensure ConnectionDomain is not empty
if ([string]::IsNullOrWhiteSpace($TenantID)) {
	throw "ConnectionDomain parameter cannot be empty"
}

# Correct command name and ensure proper parameter passing
Connect-Graph -TenantId $TenantID -AppId $AppId -Certificate $Certificate
}
catch{
	Write-Error $_.Exception.Message
}

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
$params = @{ To = $MFAPhone; From = $number; Body = "<Your MSP> Support - Please give this code to your technician to verify your identity: $Random" }

# Create a credential object for HTTP basic auth
$p = $token | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($sid, $p)

# Make API request, selecting JSON properties from response
$TwilioResponse = Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
ConvertFrom-Json | Select sid, body
try {
    $Note = ""
    if ($TwilioResponse -ne $null) {
        $Note = @"
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 20px auto; padding: 20px; border-radius: 10px; background: linear-gradient(145deg, #ffffff, #f0f0f0); box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 20px;">
        <h1 style="color: #2c3e50; margin: 0; padding: 10px; font-size: 24px; border-bottom: 2px solid #3498db;">Identity Verification Details</h1>
    </div>
    
    <div style="background: #3498db; color: white; padding: 20px; border-radius: 8px; text-align: center; margin: 15px 0;">
        <div style="font-size: 32px; font-weight: bold; letter-spacing: 3px;">$Random</div>
        <div style="font-size: 14px; margin-top: 5px;">Verification Code</div>
    </div>

    <div style="background: #fff; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #2ecc71;">
        <div style="font-size: 14px; color: #7f8c8d; margin-bottom: 5px;">Request Information</div>
        <div style="color: #2c3e50; margin-bottom: 3px;"><strong>Request ID:</strong> $RequestID</div>
        <div style="color: #2c3e50; margin-bottom: 3px;"><strong>Timestamp:</strong> $Timestamp</div>
        <div style="color: #2c3e50;"><strong>Target Number:</strong> $MFAPhone</div>
    </div>

    <div style="background: #fff; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #e74c3c;">
        <div style="font-size: 14px; color: #7f8c8d; margin-bottom: 5px;">User Details</div>
        <div style="color: #2c3e50; margin-bottom: 3px;"><strong>User:</strong> $HaloUser</div>
        <div style="color: #2c3e50; margin-bottom: 3px;"><strong>Tenant:</strong> $TenantID</div>
    </div>

    <div style="background: #fff; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #f1c40f;">
        <div style="font-size: 14px; color: #7f8c8d; margin-bottom: 5px;">Authentication Methods</div>
        <div style="color: #2c3e50; margin-bottom: 3px;"><strong>Methods:</strong> $AuthenticationMethods</div>
        <div style="color: #2c3e50;"><strong>Details:</strong> $AdditionalDetail</div>
    </div>

    <div style="background: #27ae60; color: white; padding: 10px; border-radius: 5px; text-align: center; margin-top: 20px;">
        <span style="font-size: 16px;">Twilio Response: Success</span>
    </div>
</div>
"@
    } else {
        $Note = @"
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 20px auto; padding: 20px; border-radius: 10px; background: linear-gradient(145deg, #ffffff, #f0f0f0); box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 20px;">
        <h1 style="color: #2c3e50; margin: 0; padding: 10px; font-size: 24px; border-bottom: 2px solid #e74c3c;">Identity Verification Failed</h1>
    </div>
    
    <div style="background: #e74c3c; color: white; padding: 20px; border-radius: 8px; text-align: center; margin: 15px 0;">
        <div style="font-size: 32px; font-weight: bold; letter-spacing: 3px;">$Random</div>
        <div style="font-size: 14px; margin-top: 5px;">Verification Code</div>
    </div>

    <div style="background: #fff; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #e74c3c;">
        <div style="color: #e74c3c; font-weight: bold;">Twilio Response: Failed</div>
        <div style="color: #7f8c8d; margin-top: 5px;">Please try again or contact support.</div>
    </div>
</div>
"@
    }

	$headers = @{
		'Content-Type' = 'application/json'
	}

	$HaloResponsePayload = @{
    "TicketID" = $TicketID
    "VerificationResponse" = $Note
	}

	$JsonPayload = $HaloResponsePayload | ConvertTo-Json
	$Response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $JsonPayload -Headers $headers
    
    # Output the response
    $Response
    Write-Output "Data sent to webhook successfully."
} 
catch {
    Write-Error "Failed to send data to webhook: $_.Exception.Message"
	continue
}



