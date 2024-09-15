SELECT
		aareadesc as [Client]
	,	round((select isnull(sum(pphours),0) from Prepayhistory where ppareaint=Areaint AND ppdate<@startdate) 
		- (select isnull(sum(CASE WHEN Whe_<@startdate THEN actionprepayhours END),0)),2) AS [Opening Balance]
	,	round(isnull((select isnull(sum(pphours),0) from prepayhistory where ppdate>=@startdate
		and ppdate<@enddate and ppareaint=Areaint),0),2) AS [Purchased During]
	,	round((select isnull(sum(CASE WHEN whe_ BETWEEN @startdate AND @enddate THEN actionprepayhours END),0)),2) AS [Used During]
	,	round((select isnull(sum(pphours),0) from Prepayhistory where ppareaint=Areaint AND ppdate<@enddate) 
		- (select isnull(sum(CASE WHEN Whe_<@enddate THEN actionprepayhours END),0)),2) AS [Closing Balance]
FROM Faults
JOIN Area ON areaint=Aarea
JOIN ACTIONS ON actions.faultid=faults.faultid
WHERE ActionBillingPlanID=-1
GROUP BY aareadesc, faults.Areaint
