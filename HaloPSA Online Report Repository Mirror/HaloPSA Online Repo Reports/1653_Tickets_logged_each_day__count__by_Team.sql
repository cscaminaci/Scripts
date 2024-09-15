select date_id as Date
, Weekday_nm as Weekday
, sdsectionname as Team
, (select count(*) from faults where
requesttypenew in (select rtid from requesttype where rtisopportunity=0 and rtisproject=0)
and sectio_=sdsectionname and dateoccured>start_dts and dateoccured<end_dts)as
'No. of Tickets' 
from calendar
cross join sectiondetail                                                                   
where start_dts>=@startdate and start_dts<@enddate and weekday_id not in (7,1)      and start_dts<getdate()
                                                                           


                                 




