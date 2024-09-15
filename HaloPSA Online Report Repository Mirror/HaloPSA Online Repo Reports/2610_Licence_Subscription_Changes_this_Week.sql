SELECT 
	  aareadesc as 'Customer'
	, ldesc as 'Licence'
	, CASE WHEN LCFieldId = 2 THEN N'Addition'
	       WHEN LCFieldId = 3 THEN 'Removal'
	  END AS 'Removal/Addition'
	, uusername as 'User'
	, LCWhen as 'Date of Change'
FROM LicenceChange
JOIN licence on lid = LCLid
JOIN users on uid = LCUserId
JOIN site on usite = ssitenum
JOIN area on sarea = aarea
WHERE LCWhen BETWEEN @startdate and @enddate
