select 
DAID
,DAType
,DADesc	as [Description]
,DACount as [Count]	
,DADID	
,DABundleDesc	
,DACost	as [Cost]
,DALastUsed	as [Last Used]
,DAInstalledDate	as [Installed Date]
,DASnowID	
,DALicenceRequired	as [Licence Required]
,DAVersion	as [Version]
,dauserid	
,daroleid	
,uusername as [Username] 
,aareadesc as [Customer]
from deviceapplications
left join users on uid=dauserid
left join site on ssitenum=usite
left join area on aarea=sarea
