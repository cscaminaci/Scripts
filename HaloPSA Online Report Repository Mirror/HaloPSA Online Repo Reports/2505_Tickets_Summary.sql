select 
faults.faultid as [Ticket ID],
username as [User],
tstatusdesc as [Status],
symptom as [Summary],
dateoccured as [Date Created],
datecleared as [Date Closed],
Uname as [Agent],
 [Billable Time]



from faults


left join tstatus on tstatus = status
left join uname on unum = assignedtoint


INNER JOIN (

        SELECT

            FaultID AS [AFaultID],

            SUM(TimeTaken) AS [Billable Time]

        FROM

            Actions

        WHERE

            ActIsBillable = 1

            AND ActionChargeAmount <> 0

        GROUP BY

            FaultID

    ) AS [Actions] ON FaultID = AFaultID
