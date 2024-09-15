SELECT top 100 percent
    aareadesc AS [Client],
    actions.faultid AS [Ticket ID],
    who AS [Agent],
    CAST(ROUND(ISNULL(timetaken*60, 0), 2) AS INT) AS [Time Taken (mins)],
    actoutcome AS [Action Description],
    format(whe_, 'MM/dd/yyyy') AS [Action Logged Date],
    note as [Note],
    btname as [Budget Type],
    p.faultid as [Parent ID],
    p.symptom as [Parent Summary],
    (select fvalue from lookup where fid=17 and fcode=actioncode+1) as [Charge Rate],
    CAST(ROUND(ISNULL(actionchargehours*60, 0), 2) AS INT) AS [Billable Time Taken (mins)]

FROM actions

LEFT JOIN faults c ON actions.faultid = c.faultid 
LEFT JOIN faults p on p.faultid=c.fxrefto
LEFT JOIN area ON c.areaint = aarea
LEFT JOIN requesttype ON c.requesttypenew = rtid
LEFT JOIN BudgetType on c.fbudgettype = btid

WHERE
    c.fdeleted = 0
    AND c.fmergedintofaultid = 0
    AND whe_ BETWEEN @startdate AND @enddate 
    AND timetaken>0
    AND p.requesttype=22
    

ORDER BY actions.faultid DESC, actionnumber ASC
