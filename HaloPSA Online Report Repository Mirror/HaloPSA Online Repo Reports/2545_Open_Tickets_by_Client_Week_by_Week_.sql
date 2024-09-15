select [Client],[Week Commencing],sum([open tickets]) as [Tickets Opened],sum([closed]) as [Tickets Closed Assigned], sum([closedu]) as [Tickets Closed Unassigned] from
(
(
select * from (select
        aareadesc as [Client],
         convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]
       , count(faultid) as [Open Tickets]
       ,0 as [closed], 0 as [Closedu]
from                                        
         faults
join area on aarea=areaint         
where
  dateoccured > @startdate
  and dateoccured < @enddate                                                                   
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
     convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)),aareadesc
)a)
UNION
(
select * from (
select
        aareadesc as [Client],
         convert(date,dateadd(week, datediff(week, 0, datecleared), 0)) as [Week Commencing]
         ,0 as [open]
       , count(faultid) as [Closed], 0 as [Closedu]
from                                        
         faults  
join area on aarea=areaint 
where
   status =9 and assignedtoint<>1 and
         datecleared >  @startdate
  and datecleared < @enddate                                                                     
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
     convert(date,dateadd(week, datediff(week, 0, datecleared), 0)),aareadesc
) b )
Union
(
select * from (
select
        aareadesc as [Client],
         convert(date,dateadd(week, datediff(week, 0, datecleared), 0)) as [Week Commencing]
         ,0 as [open]
       , 0 as [Closed], count(faultid) as [Closedu]
from                                        
         faults 
join area on aarea=areaint  
where
   status =9 and assignedtoint=1 and
         datecleared >  @startdate
  and datecleared < @enddate                                                                     
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
group by
     convert(date,dateadd(week, datediff(week, 0, datecleared), 0)),aareadesc
) d
))c
group by c.[week commencing],c.[Client]


