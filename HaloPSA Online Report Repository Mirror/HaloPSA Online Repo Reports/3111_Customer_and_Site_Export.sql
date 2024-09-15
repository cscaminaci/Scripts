SELECT
	  (SELECT treedesc FROM tree WHERE treeid = atreeid) as 'TopLevel'
	, aareadesc as 'CustomerName'
	, aaccountsid as 'AccountsID'
	, sdesc as 'SiteName'
	, (SELECT top 1 asline1 FROM ADDRESSSTORE WHERE ASSiteID = Ssitenum ORDER BY asid DESC) as 'AddressLine1'
	, (SELECT top 1 asline2 FROM ADDRESSSTORE WHERE ASSiteID = Ssitenum ORDER BY asid DESC) as 'AddressLine2'
	, (SELECT top 1 asline3 FROM ADDRESSSTORE WHERE ASSiteID = Ssitenum ORDER BY asid DESC) as 'AddressLine3'
	, (SELECT top 1 asline4 FROM ADDRESSSTORE WHERE ASSiteID = Ssitenum ORDER BY asid DESC) as 'AddressLine4'
	, (SELECT top 1 asline5 FROM ADDRESSSTORE WHERE ASSiteID = Ssitenum ORDER BY asid DESC) as 'PostCode'
	, SPhoneNumber as 'SitePhoneNumber'
	, SiteEmailDomain as 'SiteEmailDomain'
	, Smemo as 'SiteMemo'
FROM site
JOIN area on sarea = aarea
