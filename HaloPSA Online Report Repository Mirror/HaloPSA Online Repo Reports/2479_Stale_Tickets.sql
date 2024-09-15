SELECT    faultid         AS [Ticket ID],
          symptom         AS [Summary],
          flastactiondate AS [Last Action Occurred On],
          uname           AS [Agent],
          aareadesc       AS [Client],
          uusername       AS [User],
tstatusdesc as [Status],
rtdesc as [Ticket Type]
FROM      faults
LEFT JOIN uname
ON        unum = assignedtoint
LEFT JOIN area
ON        aarea=areaint
LEFT JOIN users
ON        uid = userid
left join requesttype on rtid = requesttypenew
left join tstatus on tstatus = status
WHERE     status NOT IN (8,9)
AND       (
                    Datediff(minute,flastactiondate,Getdate()))>120
and fdeleted=0 and fmergedintofaultid=0
