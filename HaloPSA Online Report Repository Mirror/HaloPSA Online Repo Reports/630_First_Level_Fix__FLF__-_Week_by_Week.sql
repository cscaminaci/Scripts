select       convert(date,dateadd(week, datediff(week, 0, dateoccured), 0)) as [Week Commencing]   , isnull(cast(CONVERT(DECIMAL(4,2),(count(nfaultid)/NULLIF((count(faultid)+count(nfaultid))*1.0,0)))*100 as 
integer),100) as [First Level Fix %] from faults left join(select       faultid as [nfaultid]  from faults left join (select rtid as [did],rtdefsection as [dsection] from requesttype where rtrequesttype=1 
and RTIsOpportunity=0 and
rtisproject=0)[Default] on requesttypenew=did where sectio_=dsection)[noesc] on faultid=nfaultid where status in (8,9) and dateoccured > @startdate and dateoccured < @enddate group by
convert(date,dateadd(week, datediff(week, 0, dateoccured), 0))




