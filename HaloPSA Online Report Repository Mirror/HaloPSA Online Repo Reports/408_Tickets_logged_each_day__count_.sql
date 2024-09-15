select date_id as Date
, Weekday_nm as Weekday
, (select count(*) from faults where
requesttypenew in (select rtid from requesttype where rtisopportunity=0 and rtisproject=0) and dateoccured>start_dts and dateoccured<end_dts)as
'No. of Tickets' 
from calendar                                                                     
where start_dts>=@startdate and start_dts<@enddate and weekday_id not in (7,1)      and start_dts<getdate()
                                                                           


                                 




