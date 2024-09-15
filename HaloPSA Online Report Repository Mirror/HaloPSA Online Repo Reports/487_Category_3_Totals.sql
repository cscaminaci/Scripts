select cdcategoryname as 'Category 3 Value'
, (select count(faultid) from faults where category4=cdcategoryname and dateoccured>@startdate and
dateoccured<@enddate)Total
, (select sum(timetaken) from actions where actions.faultid in (select faultid from faults where category4=cdcategoryname))as 'Total Time'   
from categorydetail  where cdtype=4                                                                             
                         









