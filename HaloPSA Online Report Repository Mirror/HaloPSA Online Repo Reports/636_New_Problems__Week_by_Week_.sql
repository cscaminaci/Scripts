select          convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]    , count(faultid) as [# Problems] from
 faults where     dateoccured > @startdate and dateoccured
< @enddate and requesttype=4 and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) group by     convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))



