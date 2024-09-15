select rtdesc as [Ticket Type]
,count(faultid) as [Count]
,USection
from faults 
join requesttype on rtid=requesttypenew 
JOIN UName on UNum = ClearWhoInt
where fdeleted=0
and @startdate<dateoccured
and @enddate>dateoccured
group by USection, rtdesc
