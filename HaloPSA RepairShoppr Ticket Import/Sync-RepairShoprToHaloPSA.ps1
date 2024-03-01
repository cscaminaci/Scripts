<#	
	.NOTES
	===========================================================================
	 Created on:   	10/31/2023 4:58 PM
	 Created by:   	Christopher Scaminaci
	 Organization: 	TechPulse Professional Services
	 Filename:     	Sync-RepairShoprToHaloPSA.ps1
	===========================================================================
	.DESCRIPTION
		This script imports contacts and open tickets from RepairShoppr to HaloPSA. 
		It will match the contact to the user in HaloPSA if they exist otherwise it will fall back to general user for the client.
		The order of actions is preserved but the formatting of the HTML is typically not.
		This is really only meant to be used to bring their open tickets over at cutover time.
#>
$apiEndpoint = "<REPAIRSHOPPR API ENDPOINT URL>"
$apiKey = "<REPAIRSHOPPR API KEY>"
$haloAgentURL = "<halo agent url>"
$haloClientID = "<halo client ID>"
$haloClientSecret = "<halo client secret>"
$haloTenant = "<halo tenant name>"

$headers = @{
	"Authorization" = "Bearer $apiKey"
}

function Get-OpenRepairShoprTickets
{
	$totalpages = 0
	$currentpage = 1
	$alltickets = @() # Initialize as an empty array
	
	# Make the first API request to get tickets and meta information
	$response = Invoke-RestMethod -Uri "$apiEndpoint/api/v1/tickets?status=Not%20Closed" -Method Get -Headers $headers
	$alltickets += $response.tickets # Add the tickets to the alltickets array
	$totalpages = $response.meta.total_pages
	$currentpage++
	
	# Loop through the rest of the pages to get all tickets
	while ($currentpage -le $totalpages) # Changed -lt to -le to include the last page
	{
		$TicketResponse = Invoke-RestMethod -Uri "$apiEndpoint/api/v1/tickets?status=Not%20Closed&page=$currentpage" -Method Get -Headers $headers
		$alltickets += $TicketResponse.tickets # Add the new tickets to the alltickets array
		$currentpage++
	}
	
	# Return the list of open tickets
	return $alltickets
}

function Get-RepairShoprClientFromID
{
	param (
		$ClientID
	)
	
	$response = Invoke-RestMethod -Uri "$apiEndpoint/api/v1/customers/$ClientID" -Method Get -Headers $headers
	
	return $response
}

function Get-RepairShoprTicketByID
{
	param (
		$TicketID
	)
	
	$response = Invoke-RestMethod -Uri "$apiEndpoint/api/v1/tickets/$TicketID" -Method Get -Headers $headers
	
	return $response
}

function Get-RepairShoprUserFromID
{
	param (
		$UserID
	)
	
	$response = Invoke-RestMethod -Uri "$apiEndpoint/api/v1/users/$UserID" -Method Get -Headers $headers
	
	return $response
}

# Example usage
$openTickets = Get-OpenRepairShoprTickets

Connect-HaloAPI -ClientID $haloClientID -Tenant $haloTenant -URL $haloAgentURL -ClientSecret $haloClientSecret -Scopes "all"

foreach ($ticket in $openTickets)
{
	$FetchedTicket = Get-RepairShoprTicketByID -TicketID $ticket.id
	#$RSClient = Get-RepairShoprClientFromID -ClientID $ticket.customer_id
	# Your date string from RepairShopr
	$repairShoprDate = $ticket.created_at
	
	# Convert it to a DateTime object
	$dateTime = Get-Date -Date $repairShoprDate
	
	# Format it to ISO 8601
	$haloDate = $dateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
	
	$initialIssueComment = $ticket.comments | Where-Object { $_.subject -eq 'Initial Issue' }
	$agent = Get-HaloAgent -Search "$($ticket.user.email)"
	Start-Sleep -Milliseconds 1000
	#$RSUser = Get-RepairShoprUserFromID -UserID $FetchedTicket
	$ClientSearch = Get-HaloClient -Search "$($ticket.customer_business_then_name)"
	Start-Sleep -Milliseconds 1000
	$UserSearch = Get-HaloUser -Search "$($FetchedTicket.ticket.contact.email)"
	Start-Sleep -Milliseconds 1000
	# Initialize an empty array to hold the formatted comments
	$commentList = @()
	
	# Loop through each comment in the ticket
	foreach ($comment in $ticket.comments)
	{
		# Skip the comment if its subject is "Initial Issue"
		if ($comment.subject -ne 'Initial Issue')
		{
			# Determine the label to use ('Initial issue' or 'Update')
			$label = if ($comment.subject -eq 'Initial Issue') { 'Initial issue' } else { 'Update' }
			
			# Create the formatted comment string
			$formattedComment = "$label : $($comment.body)"
			
			# Add the formatted comment to the list
			$commentList += $formattedComment
		}
	}
	
	# Join all the formatted comments into a single string, separated by newlines and HTML breaks
	$details = ($commentList -join " <br/><br/> ")
	
	# If ClientSearch and UserSearch return an array, take the first object
	$clientId = if ($ClientSearch -eq $null) { $null } else { $ClientSearch[0].id }
	$clientName = if ($ClientSearch -eq $null) { $null } else { $ClientSearch[0].name }
	$userId = if ($UserSearch -eq $null) { $null } else { $UserSearch[0].id }
	$userName = if ($UserSearch -eq $null) { $null } else { $UserSearch[0].name }
	
	$TicketHashTable = @{
		"Summary"	    = $ticket.subject
		"details"	    = "Initial issue: $($initialIssueComment.body)"
		"client_id"	    = $clientId
		"client_name"   = $clientName
		"user_name"	    = $userName
		"user_id"	    = $userId
		"dateoccurred"  = $haloDate
		"tickettype_id" = 1
		"team"		    = "Support"
		"agent_id"	    = if ($agent -eq $null) { $null } else { $agent.id }
		"sendack"	    = $false
	}
	
	Write-Host "TicketHashTable: $($TicketHashTable | Out-String)"
	
	$PostedTicket = New-HaloTicket -Ticket $TicketHashTable
	Start-Sleep -Milliseconds 1000
	
	if ($PostedTicket -ne $null)
	{
		$CommentHashTable = @{
			"ticket_id"   = $PostedTicket.id
			"note_html"   = $details
			"who_agentid" = if ($agent -eq $null) { $null } else { $agent.id }
			"hiddenfromuser" = $true
			"outcome"	  = "Log Action"
			"outcome_id"  = 7
		}
		
		Write-Host "CommentHashTable: $($CommentHashTable | Out-String)"
		
		New-HaloAction -Action $CommentHashTable
		Start-Sleep -Milliseconds 1000
	}

}
