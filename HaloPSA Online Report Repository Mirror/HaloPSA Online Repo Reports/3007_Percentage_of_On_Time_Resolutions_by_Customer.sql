select distinct
aareadesc as [Contact],
(fc.[Response SLA Hit]*100/fe.[ResolutionTotalTickets]) as [Resolution %]
from faults
outer apply (select count(*) [Response SLA Hit] from faults where fdeleted = 0 and fmergedintofaultid < 1 and sectio_ like '%Line%' and requesttype in (1,3) and slaresponsestate = 'I' and fexcludefromsla = 0 and slaid != 4 and dateoccured between @startdate and @enddate and dateoccured=datecreated group by convert(nvarchar(7),dateoccured,126))fc

outer apply (select count(*) [ResolutionTotalTickets] from faults where fdeleted = 0 and fmergedintofaultid < 1 and sectio_ like '%Line%' and requesttype in (1,3) and fexcludefromsla = 0 and slaid != 4 and dateoccured between @startdate and @enddate group by convert(nvarchar(7),dateoccured,126))fe

join area on areaint = aarea
