select
         convert(nvarchar(7), datecleared, 126) as [Date Solved]
       , count(faultid) as [# Tickets]
from
         faults
where 
         datecleared > @startdate
  and datecleared < @enddate
  and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
and  clearance not like 'Treated As SPAM'
group by
    convert(nvarchar(7), datecleared, 126)


                                   










