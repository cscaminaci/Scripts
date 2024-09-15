
select (select aareadesc from area where aarea=(select areaint from faults where faultid in (select ohfaultid from ORDERHEAD where ohid=olid))) as [Client]
,(select uname from uname where unum=(select Assignedtoint from faults where faultid in (select ohfaultid from ORDERHEAD where ohid=olid))) as [Technician]
,OLDesc as [Item Description]
,OLorderqty as [Quantity]
,OLSellingPrice as [Sale Price]
from orderline
Where (select dateoccured from faults where faultid in (select ohfaultid from ORDERHEAD where ohid=olid))>@startdate and (select dateoccured from faults where faultid in (select ohfaultid from ORDERHEAD where ohid=olid))<@enddate
