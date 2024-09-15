SELECT
	  aareadesc as 'Client'
	, uusername as 'Name'
	, uemail as 'Email'
	, uother2 as 'Job Title'
	, STRING_AGG(stdesc, ', ') as 'Subscribed Services'
FROM users
JOIN site on usite = Ssitenum
JOIN area on sarea = aarea
JOIN SERVICEUSER on suuid = uid
JOIN servsite on suid = stid
WHERE uinactive = 0
  AND uusername != 'Generic User'
GROUP BY uusername, uemail, uother2, aareadesc
