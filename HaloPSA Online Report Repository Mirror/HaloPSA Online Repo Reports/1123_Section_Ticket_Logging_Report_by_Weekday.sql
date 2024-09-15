select SDSectionName  as [Section]
,(select count(faultid) from faults where datepart(weekday,dateoccured) in (2,3,4,5,6) and SDsectionname=sectio_ and @startdate<dateoccured and dateoccured<@enddate) as [Tickets logged in week]
,(select count(faultid) from faults where datepart(weekday,dateoccured) in (1,7) and SDsectionname=sectio_ and status=9 and @startdate<dateoccured and dateoccured<@enddate) as [Tickets logged at weekend]
,(select count(faultid) from faults where datediff(hh,dateoccured,datecleared)<24 and SDSectionName=sectio_ and status=9 and @startdate<dateoccured and dateoccured<@enddate) as [Tickets closed within 24 hours]
,(select count(faultid) from faults where datediff(dd,dateoccured,datecleared) <7 and datediff(dd,dateoccured,datecleared) >1 and SDSectionName=sectio_ and status=9 and @startdate<dateoccured and dateoccured<@enddate) as [Tickets closed between 1 and 7 days]
,(select count(faultid) from faults where datediff(dd,dateoccured,datecleared)>7 and SDSectionName=sectio_ and status=9 and @startdate<dateoccured and dateoccured<@enddate) as [Tickets closed after 7 days]
from SectionDetail
