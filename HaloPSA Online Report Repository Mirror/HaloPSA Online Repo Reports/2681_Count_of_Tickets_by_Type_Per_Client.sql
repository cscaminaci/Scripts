select rtdesc as [Ticket Type]
,count(faultid) as [Count]
, aareadesc as [Client]
from faults 
join requesttype on rtid=requesttypenew 
join area on aarea=areaint
where fdeleted=0
and @startdate<dateoccured
and @enddate>dateoccured
group by rtdesc, aareadesc
