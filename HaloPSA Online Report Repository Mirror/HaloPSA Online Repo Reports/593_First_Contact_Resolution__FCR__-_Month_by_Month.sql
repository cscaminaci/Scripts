select
    convert(nvarchar(7), dateoccured, 126) as [Date],
    isnull(cast(CONVERT(DECIMAL(4,2),(count(ffaultid)/NULLIF((count(ffaultid)+count(mfaultid))*1.0,0)))*100 as integer),100) as [First Time Fix %]
from faults
left join
(select faultid as [ffaultid] from faults where ffirsttimefix=1)first on faultid=ffaultid left join
(select faultid as [mfaultid] from faults where ffirsttimefix=0)multiple on faultid=mfaultid
where requesttype=1 and fdeleted=0
and dateoccured > @startdate and dateoccured<@enddate
group by convert(nvarchar(7), dateoccured, 126)










