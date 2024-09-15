SELECT [Client]
	,[Fault ID]
	,[Raised]
	,[Summary]
	,[Hours Used]
	,round((
			SELECT sum(pphours)
			FROM Prepayhistory
			WHERE ppareaint = b.[ClientID]
				AND [Raised] >= ppdate
			) - (
			SELECT sum(actionprepayhours)
			FROM actions
			join faults on actions.faultid=faults.faultid
			WHERE areaint = b.[ClientID]
					AND whe_ <= [Raised]
					
			), 2) [Hours Left]
FROM (
	SELECT (
			SELECT aareadesc
			FROM area
			WHERE areaint = aarea
			) AS [Client]
		,areaint  as [ClientID]
		,faults.faultid AS [Fault ID]
		,whe_ AS [Raised]
		,symptom AS [Summary]
		,convert(NVARCHAR(1000),round(actionprepayhours, 2)) AS [Hours Used]
	FROM faults
	JOIN actions ON faults.faultid = actions.faultid
		AND actionprepayhours > 0
	

UNION

SELECT (
		SELECT aareadesc
		FROM Area
		WHERE aarea = ppareaint
		) AS [Client]
	,ppareaint as [ClientID]
	,0 AS [Fault ID]
	,ppdate AS [Raised]
	,'Pre Pay added' AS [Summary]
	,cast(('+' + cast(pphours AS NVARCHAR(1000))) AS NVARCHAR(1000)) AS [Hours Used]
FROM Prepayhistory) b

