/*Column for the agent assigned to the ticket at the time of the date value*/
(SELECT UName FROM UName WHERE UNum = (SELECT TOP 1 ATo FROM Audit WHERE AFaultID = FaultID AND AValue = 'Agent_ID' AND ADate < @EndDate ORDER BY ADate DESC))
                                                                                     /*^*/                                       /*^*/
                                                                        /*Ticket Column of your choice*/             /*Date Value of your choice*/
