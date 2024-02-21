param(
    [string]$ClientID
)

if ($ClientID) {
    $clients = @(Get-HaloClient -ClientID $ClientID)
} else {
    $clients = @(Get-HaloClient)
}

$clientCount = $clients.Count
$clientIndex = 0

foreach ($client in $clients) {
    $clientIndex++
    $tickets = Get-HaloTicket -ClientID $client.id
    $ticketCount = $tickets.Count
    $ticketIndex = 0

    Write-Progress -Id 1 -Activity "Processing Clients" -Status "Processing $($client.name) - $($clientIndex) of $($clientCount)" -PercentComplete (($clientIndex / $clientCount) * 100)

    $ids = $tickets.id

    foreach ($id in $ids) {
        $ticketIndex++

        Write-Progress -Id 2 -Activity "Processing Tickets for Client $($client.name)" -Status "Processing Ticket $($ticketIndex) of $($ticketCount)" -PercentComplete (($ticketIndex / $ticketCount) * 100) -ParentId 1

        $Ticket = Get-HaloTicket -TicketID $id
        sleep 1

        if (-not $Ticket.isbillable) {
            $Ticket.isbillable = $true
            Set-HaloTicket -Ticket $Ticket
            Write-Output "Ticket ID $id marked as billable."
        } else {
            Write-Output "Ticket ID $id is already marked as billable, no action taken."
        }

        sleep 1

        $Actions = Get-HaloAction -TicketID $id -AgentOnly
        Write-Output "Got $($Actions.count) actions for ticket with ID $id"

        foreach ($act in $Actions) {
            Write-Output "Updating Action ID $($act.id)"
            try {
                $act | Add-Member -NotePropertyName actreviewed -NotePropertyValue 'False' -Force
                Set-HaloAction -Action $act
                sleep 1
            } catch {
                Write-Output "Caught an exception - $($_.Exception.Message) - continuing"
                continue
            }
        }
    }

    Write-Progress -Id 2 -Activity "Processing Tickets for Client $($client.name)" -Status "Completed" -Completed
}

Write-Progress -Id 1 -Activity "Processing Clients" -Status "Completed" -Completed
