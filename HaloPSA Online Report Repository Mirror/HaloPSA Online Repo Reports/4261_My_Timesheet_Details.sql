
SELECT 
    [Agent], 
    [Date], 
    [Start], 
    [End], 
    [Time Taken (Hours)], 
    ROUND([GTH], 3) AS [Grand Total (Hours)(All Time in This Report)], 
    ROUND([GTM], 3) AS [Grand Total (Minutes)(All Time in This Report)], 
    [Action Performed], 
    [Time Taken (Minutes)], 
    [Ticket No], 
    [Summary], 
    (select LogoutRedirectUri from NHD_IDENTITY_Application where ClientId='24fe0a24-85d5-46d4-b9c6-721e23f25843') as [URL],
    [Notes]
FROM
(
    SELECT 
        who AS [Agent], 
        FORMAT(actionarrivaldate at time zone (select rtimezone from control3), 'MM/dd/yyyy') AS [Date],
        ActionArrivalDate AS [Start], 
        ActionCompletionDate AS [End], 
        CASE WHEN timetaken IS NULL THEN ROUND(traveltime, 3) ELSE ROUND(timetaken, 3) END AS [Time Taken (Hours)],
        SUM(timetaken) OVER() AS [GTH],
        actoutcome AS [Action Performed], 
        CASE WHEN timetaken IS NULL THEN TravelTime * 60 ELSE DATEDIFF(mi, ActionArrivalDate, ActionCompletionDate) END AS [Time Taken (Minutes)],
        SUM(CASE WHEN timetaken IS NULL THEN TravelTime * 60 ELSE DATEDIFF(mi, ActionArrivalDate, ActionCompletionDate) END) OVER() AS [GTM],
        act.faultid AS [Ticket No], 
        fa.Symptom AS [Summary], 
        note AS [Notes]
    FROM 
        actions act 
        LEFT JOIN faults fa ON act.Faultid = fa.Faultid
    WHERE whoagentid = $agentid
        AND ActionArrivalDate at time zone (select rtimezone from control3) BETWEEN @startdate AND @enddate 
        AND (ISNULL(timetaken, 0) + ISNULL(TravelTime, 0)) <> 0
) AS [Data]
