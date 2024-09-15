select cdcategoryname as 'Category 3 Value'
, (select count(faultid) from faults where category4=cdcategoryname and fdeleted=0 and dateoccured>@startdate and
dateoccured<@enddate)Total
from categorydetail where cdtype=5     
                            






