SELECT 
Actions.FaultID AS [Ticket ID],
Actions.Whe_ AS [When],
Actions.Who AS [Performed By],
Actions.ActOutcome AS [Action Type],
Actions.TimeTaken * 60 AS [Time Taken (Minutes)],
IIF((Actions.ActOutcome = 'First User Email' OR Actions.ActOutcome LIKE '%Email Updat%'), 'Subject: '+Actions.AEmailSubject, Actions.Note) AS [Note]

FROM Actions
JOIN Faults ON Actions.FaultID = Faults.FaultID

WHERE Faults.DateOccured BETWEEN @StartDate AND @EndDate
