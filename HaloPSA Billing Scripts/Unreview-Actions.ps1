$clients = Get-HaloClient
$clientCount = $clients.Count
$clientIndex = 0

foreach ($client in $clients) {
    $clientIndex++
    $tickets = get-haloticket -clientid $($client.id)
    $ticketCount = $tickets.Count
    $ticketIndex = 0

    Write-Progress -Id 1 -Activity "Processing Clients" -Status "Processing $($client.name) - $($clientIndex) of $($clientCount)" -PercentComplete (($clientIndex / $clientCount) * 100)

    $ids = $tickets.id

    # Iterate through each ticket ID
    foreach ($id in $ids) {
        $ticketIndex++
        # Optionally log the ticket ID being checked
        # "Checking for actions on ticket with ID: $id" | Out-Null

        Write-Progress -Id 2 -Activity "Processing Tickets for Client $($client.name)" -Status "Processing Ticket $($ticketIndex) of $($ticketCount)" -PercentComplete (($ticketIndex / $ticketCount) * 100) -ParentId 1

        $Ticket = Get-HaloTicket -TicketID $id
        sleep 1

        # Check if isbillable is not $true before setting it
        if (-not $Ticket.isbillable) {
            $Ticket.isbillable = $true
            Set-HaloTicket -Ticket $Ticket | Out-Null
            "Ticket ID $id marked as billable." | Out-Null  # Optionally log this action
        } else {
            "Ticket ID $id is already marked as billable, no action taken." | Out-Null  # Optionally log this action
        }

        sleep 1

        $Actions = Get-HaloAction -TicketID $id -AgentOnly
        "Got $($Actions.count) actions for ticket with ID $id" | Out-Null  # Optionally log this info

        foreach ($act in $Actions) {
            "Updating Action ID $($act.id)" | Out-Null  # Optionally log this action
            $act | Add-Member -NotePropertyName actreviewed -NotePropertyValue 'False'
            # Set the item
            Set-HaloAction -Action $act | Out-Null
            sleep 1
        }
    }

    # Ensure the ticket progress bar is completed before moving to the next client
    Write-Progress -Id 2 -Activity "Processing Tickets for Client $($client.name)" -Status "Completed" -Completed
}

# Ensure the client progress bar is completed after all clients are processed
Write-Progress -Id 1 -Activity "Processing Clients" -Status "Completed" -Completed
