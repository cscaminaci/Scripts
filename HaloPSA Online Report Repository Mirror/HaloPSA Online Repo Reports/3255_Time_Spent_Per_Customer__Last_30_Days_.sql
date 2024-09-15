SELECT *
	,Rank() OVER (
		ORDER BY [Time Logged] DESC
		) AS [Rank]
FROM (
	SELECT aareadesc AS [Client]
		, round(sum(timetaken),2) AS [Time Logged]
	FROM area
    left join faults on aarea = areaint
    left join actions on actions.faultid = faults.faultid
    WHERE dateoccured > getdate() - 28
				AND dateoccured < getdate()
                                and requesttypenew = 1
                                and fdeleted=0
	GROUP BY aareadesc
    ) d

where [Time Logged]>0
