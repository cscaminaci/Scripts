select aareadesc as [Customer name]

, sdesc as [Site name]


, (select rtdesc from REQUESTTYPE where rtid=requesttypenew) as [Request type]

, COUNT(faultid)  as [Count]

, (select COUNT(*) from DEVICE where Dsite=Ssitenum) as [Number of assets]

from area

join Site on Sarea=aarea

join Faults on sitenumber=Ssitenum and Areaint=aarea
where dateoccured>@startdate and dateoccured<@enddate
 group by aareadesc, sdesc, requesttypenew, ssitenum
