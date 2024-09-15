select top 100000
dinvno as [Device Number],
tdesc as [Device Type],
aareadesc as [Customer],
sdesc as [Site],
cast(case when ddomotzid > 0 then 'Yes' else 'No' end as nvarchar(100)) as [Domotz],
cast(case when dninjarmmid > 0 then 'Yes' else 'No' end as nvarchar(100)) as [Ninja],
cast(case when dninjarmmid > 0 then 'green' else 'red' end as nvarchar(100)) as [color],
ddomotzid
from device
join xtype on ttypenum=dtype
join site on ssitenum=dsite
join area on sarea=aarea
order by tdesc 
