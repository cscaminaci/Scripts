SELECT
	  uusername as 'User'
	, uemail as 'Email Address'
	, UIsImportantContact as 'Important Contact'
	, sdesc as 'Site'
	, aareadesc as 'Client'
	, AisVIP as 'Important Client'
FROM users
JOIN site on Usite = Ssitenum
JOIN area on aarea = Sarea
WHERE uusername != 'General User'
