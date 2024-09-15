SELECT
    F.FaultID AS [Ticket ID],
    Whe_ AS [Action Time],
    Who AS [Action Agent],
    Note AS [Action Note]
FROM
    Faults F
    INNER JOIN Actions A ON F.FaultID = A.FaultID AND TimeTaken > 0
