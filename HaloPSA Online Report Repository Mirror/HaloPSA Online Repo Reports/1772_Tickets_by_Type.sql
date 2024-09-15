select tstatusdesc as [Status],count(*) as [Count] from faults 
left join tstatus on tstatus=status
where fdeleted=0 and @startdate<dateoccured and @enddate>dateoccured
group by tstatusdesc
