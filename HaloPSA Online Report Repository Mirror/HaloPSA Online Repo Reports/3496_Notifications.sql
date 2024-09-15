SELECT
    emfaultid AS [Ticket ID],
    mbname AS [Ticket Mailbox],
    emmailaddr AS [To],
    emmessage AS [Message],
    unname AS [Notification],
    emunid AS [Notification ID],
    emdate AS [Date],
    ememailstatus AS [Email Status]
FROM
    escmsg
    LEFT JOIN unamenotification ON emunid = unid
    LEFT JOIN faults ON emfaultid = faultid
    LEFT JOIN mailbox ON mbid = fmailboxid

