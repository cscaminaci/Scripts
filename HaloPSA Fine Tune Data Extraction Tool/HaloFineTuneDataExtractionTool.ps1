<#
.----------------. .----------------. .----------------.   .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. 
| .--------------. | .--------------. | .--------------. | | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. |
| | ____    ____ | | |    _______   | | |   ______     | | | |      __      | | | _____  _____ | | |  _________   | | |     ____     | | | ____    ____ | | |      __      | | |  _________   | | |     ____     | | |  _______     | |
| ||_   \  /   _|| | |   /  ___  |  | | |  |_   __ \   | | | |     /  \     | | ||_   _||_   _|| | | |  _   _  |  | | |   .'    `.   | | ||_   \  /   _|| | |     /  \     | | | |  _   _  |  | | |   .'    `.   | | | |_   __ \    | |
| |  |   \/   |  | | |  |  (__ \_|  | | |    | |__) |  | | | |    / /\ \    | | |  | |    | |  | | | |_/ | | \_|  | | |  /  .--.  \  | | |  |   \/   |  | | |    / /\ \    | | | |_/ | | \_|  | | |  /  .--.  \  | | |   | |__) |   | |
| |  | |\  /| |  | | |   '.___`-.   | | |    |  ___/   | | | |   / ____ \   | | |  | '    ' |  | | |     | |      | | |  | |    | |  | | |  | |\  /| |  | | |   / ____ \   | | |     | |      | | |  | |    | |  | | |   |  __ /    | |
| | _| |_\/_| |_ | | |  |`\____) |  | | |   _| |_      | | | | _/ /    \ \_ | | |   \ `--' /   | | |    _| |_     | | |  \  `--'  /  | | | _| |_\/_| |_ | | | _/ /    \ \_ | | |    _| |_     | | |  \  `--'  /  | | |  _| |  \ \_  | |
| ||_____||_____|| | |  |_______.'  | | |  |_____|     | | | ||____|  |____|| | |    `.__.'    | | |   |_____|    | | |   `.____.'   | | ||_____||_____|| | ||____|  |____|| | |   |_____|    | | |   `.____.'   | | | |____| |___| | |
| |              | | |              | | |              | | | |              | | |              | | |              | | |              | | |              | | |              | | |              | | |              | | |              | |
| '--------------' | '--------------' | '--------------' | | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
 '----------------' '----------------' '----------------'   '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' 

 HaloPSAFineTuneDataExtractionTool.ps1                                      
 Author: Ceej Scaminaci - The MSP Automator                                   
 Website: mspautomator.com                                                  
 Copyright 2023       
#>

function Get-HaloPSAToken
{
	
	$HaloClientID = "<CLIENT ID>"
	$HaloClientSecret = "<CLIENT SECRET>"
	
	$uri = "https://YOURHALOPSAURL.HALOPSA.COM/auth/token"
	
	$header_token = @{ "Content-Type" = "application/x-www-form-urlencoded" }
	
	$creds = @{
		client_id = "$HaloClientID"
		client_secret = "$HaloClientSecret"
		grant_type = "client_credentials"
		scope	  = "all"
	}
	
	$Response = Invoke-RestMethod -Uri $uri -Method 'Post' -Body $creds -Headers $header_token
	
	$AccessToken = $Response.access_token
	
	return $AccessToken
}

function Get-HaloTicketActions
{
	param
	(
		[parameter(Mandatory = $true)]
		$TicketID
	)
	
	try
	{
		
		$Headers = @{
			'Content-Type'  = 'application/json'
			'Authorization' = "Bearer $Token"
		}
		
		
		
		$Response = Invoke-RestMethod "https://YOURHALOPSAURL.HALOPSA.COM/api/actions?ticket_id=$TicketID" -Method 'GET' -Headers $headers -EA Stop
		
		return $Response
	}
	catch
	{
		Write-Host "Get Ticket Actions failed - $_" -Type ERR
		return $null
	}
}

$Global:Token = Get-HaloPSAToken
$Global:DataPromptList = [System.Collections.Generic.List[Object]]::new()

#This list needs to include ticket numbers of closed tickets to train on
$Global:ImportList = Import-Csv -Path "C:\Users\username\path_to_closed_tickets.csv"

#Set up these filters as necessary
$Global:TicketsToScan = $ImportList | Where-Object { $_.ClearanceNote -ne "$null" -and $_.ClearanceNote -notmatch "Closed via Merge" -and $_.ClearanceNote -notmatch "Automated Closure Sent" -and $_.ClearanceNote -notmatch "#NAME?"} | Sort-Object -Property RequestID -Descending
$i = 0
$total = $TicketsToScan.count

foreach ($ticket in $TicketsToScan)
{
	$i++
	Write-Output "Processing Ticket ID $($ticket.RequestID)"
	
	$ActionData = Get-HaloTicketActions -TicketID $ticket.RequestID | Sort-Object -Property actions.id
	$PromptStart = "Subject of helpdesk request: $($ticket.Summary)\n\n###\n\n"
	$Completion = "[Outcome] $($Completion)"
	$ActionCount = $ActionData.record_count
	Write-Output "Got $($ActionData.record_count) actions for Ticket"
	$ProcessedCount = 0
	$RuleHit = $false
	DO
	{
		if ($ActionData.actions[$ProcessedCount].outcome -match "First User Email")
		{
			Write-Output "Rule hit - First User email found for $($ticket.RequestID) at action ID $ProcessedCount"
			$FirstMessage = "[Customer] $($ActionData.actions[$ProcessedCount].note)\n\n"
			$RuleHit = $true
			$ProcessedCount++
		}
		elseif ($ActionData.actions[$ProcessedCount].outcome -match "Email User")
		{
			Write-Output "Rule hit - agent response found for $($ticket.RequestID) at action ID $ProcessedCount"
			$AddMessage = "[Agent] $($ActionData.actions[$ProcessedCount].note)\n\n"
			$MessageString = $MessageString + $AddMessage
			$RuleHit = $true
			$ProcessedCount++
		}
		elseif ($ActionData.actions[$ProcessedCount].outcome -match "Email Update")
		{
			Write-Output "Rule hit - User response found for $($ticket.RequestID) at action ID $ProcessedCount"
			$AddMessage = "[Customer] $($ActionData.actions[$ProcessedCount].note)\n\n"
			$MessageString = $MessageString + $AddMessage
			$RuleHit = $true
			$ProcessedCount++
		}
		else
		{
			Write-Output "Action ID $ProcessedCount is of type $($ActionData.actions[$ProcessedCount].outcome)- skipping"
			$ProcessedCount++
		}
	}
	while ($ProcessedCount -le $ActionCount)
	
	if ($RuleHit)
	{
		
		
		# Construct the full conversation with additional information
		$FormattedPrompt = $PromptStart + $FirstMessage + $MessageString
		
		
		$FormattedPrompt = $FormattedPrompt -replace '"', '\"'
		$FormattedPrompt = $FormattedPrompt -replace "'", "\'"
		$FormattedPrompt = $FormattedPrompt -replace "`n", " "
		$FormattedPrompt = $FormattedPrompt -replace "`r", " "
		$FormattedPrompt = $FormattedPrompt -replace "`t", " "
		$FormattedPrompt = $FormattedPrompt -replace "\s+", " "
		$Completion = $Completion -replace '"', '\"'
		$Completion = $Completion -replace "'", "\'"
		$Completion = $Completion -replace "`n", " "
		$Completion = $Completion -replace "`r", " "
		$Completion = $Completion -replace "`t", " "
		$Completion = $Completion -replace "\s+", " "
		$PromptToAdd = [PSCustomObject][Ordered]@{
			prompt	   = "$($FormattedPrompt)"
			completion = "$($Completion)"
		}
		$DataPromptList.Add($PromptToAdd)
		$PromptToAdd | Export-Csv -Path "C:\Users\username\export.csv" -NoTypeInformation -Append
		
		Clear-Variable -Name FormattedPrompt
		Clear-Variable -Name MessageString
		Clear-Variable -Name PromptStart
		Clear-Variable -Name FirstMessage
		Clear-Variable -Name AddMessage
	}
	else
	{
		Write-Output "No rules hit for ticket ID $($ticket.RequestID) - skipping"
		
		Clear-Variable -Name FormattedPrompt
		Clear-Variable -Name MessageString
		Clear-Variable -Name PromptStart
		Clear-Variable -Name FirstMessage
		Clear-Variable -Name AddMessage
	}
	
	Write-Progress -Activity "Processing Tickets" -Status "Processed: $i of $total" -PercentComplete ($i/$total * 100)
}
