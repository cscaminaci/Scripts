select aareadesc as [Client Name]
,sdesc as [Site Name]
,aaccountsid as [Accounts ID]
,sphonenumber as [Site Telephone]
,siteemaildomain as [INCOMING EMAIL DOMAIN]
,amemo as [Memo]
from area join site on aarea = sarea
