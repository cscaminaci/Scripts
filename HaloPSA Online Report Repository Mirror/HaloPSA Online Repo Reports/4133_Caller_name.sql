select
    clcallerid as [Phone Number],
    clusername as [Name],
    (select aareadesc from area where aarea=clarea) as [Customer],
    count(clusername) as [Count]
from
    calllog
where
    clcallerid not like '' and
    clusername not like ''
group by
    clusername,
    clcallerid,
    clarea
