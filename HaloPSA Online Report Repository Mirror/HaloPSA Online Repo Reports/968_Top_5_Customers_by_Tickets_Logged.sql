select top 5 * from
(select aareadesc as [Customer]
      , (select count(*) from faults where aarea=areaint and dateoccured>=@startdate and dateoccured<@enddate) as [Tickets]
from area
)z
order by [Tickets] desc
