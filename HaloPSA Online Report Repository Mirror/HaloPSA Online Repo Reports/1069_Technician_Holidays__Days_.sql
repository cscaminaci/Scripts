SELECT *
FROM (
	SELECT (
			SELECT uname
			FROM uname
			WHERE HTechnicianID = unum
			) AS [Technician]
		,date_year AS [Year]
		,isnull([1], 0) AS [Jan]
		,isnull([2], 0) AS [Feb]
		,isnull([3], 0) AS [Mar]
		,isnull([4], 0) AS [Apr]
		,isnull([5], 0) AS [May]
		,isnull([6], 0) AS [Jun]
		,isnull([7], 0) AS [Jul]
		,isnull([8], 0) AS [Aug]
		,isnull([9], 0) AS [Sep]
		,isnull([10], 0) AS [Oct]
		,isnull([11], 0) AS [Nov]
		,isnull([12], 0) AS [Dec]
	FROM (
		SELECT DISTINCT HTechnicianID
			,date_year
			,date_month
			,count(*) OVER (
				PARTITION BY HTechnicianID
				,date_year
				,date_month
				) AS [xC]
		FROM (
			SELECT DISTINCT ID
				,HTechnicianID
				,HDuration
				,date_year
				,date_month
			FROM holidays
			JOIN calendar ON date_year = datepart(year, hdate)
				AND date_month = datepart(month, hdate)
			WHERE HDuration > 0
				AND HType=1
			) a
		) src
	pivot(max([xC]) FOR date_month IN (
				[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				)) pvr
	) a



