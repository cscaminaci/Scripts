select       convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]     , isnull(cast(CONVERT(DECIMAL(4,2),(count(afaultid)/NULLIF((count(afaultid)+count(rfaultid))*1.0,0)))*100 as integer),100) as 
[Acceptance Rate %] from faults left join (select faultid as [rfaultid] from faults where requesttype=2 and fchangestatus=1 and fdeleted=0) as [Rejected] on rfaultid=faultid left join (select faultid as [afaultid] from faults where requesttype=2 and 
fchangestatus=2) as [Approved] on afaultid=faultid where requesttype=2 and dateoccured > @startdate and fdeleted=0 and dateoccured < @enddate group by convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))     


