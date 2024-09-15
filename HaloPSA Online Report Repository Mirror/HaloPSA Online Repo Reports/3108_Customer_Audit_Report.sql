SELECT
	  (SELECT uname FROM uname WHERE aunum = unum) as 'Agent'
	, adate as 'Date'
	, AValue as 'Entity'
	, CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE afrom = unum)
		   ELSE AFrom 
	  END AS 'Changed From'
	, CASE WHEN AValue IN ('accountmanagertech', 'sectech', 'pritech') THEN (SELECT uname FROM uname WHERE ato = unum)
		   ELSE ato 
	  END AS 'Changed To'
	, (SELECT aareadesc FROM area WHERE id = aarea) as 'Customer'
FROM audit
WHERE atablename = 'area'
