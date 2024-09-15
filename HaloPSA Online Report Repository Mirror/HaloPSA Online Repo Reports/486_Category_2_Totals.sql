select cdcategoryname as 'Category 2 Value'
, (select count(faultid) from faults where category3=cdcategoryname and fdeleted=0 and dateoccured>@startdate and dateoccured<@enddate)Total
, (select sum(timetaken) from actions where actions.faultid in (select faultid from faults where category3=cdcategoryname and fdeleted=0))as 'Total Time'
from categorydetail where cdtype=3      
                          






