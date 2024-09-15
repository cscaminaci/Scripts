select date_id as Date
, Weekday_nm as Weekday
, (select count(*) from faults where
requesttypenew in (select rtid from requesttype where rtisopportunity=0 and rtisproject=0) and dateoccured>start_dts and dateoccured<end_dts and dateoccured > getdate()-30)as
'No. of Tickets Opened' 
, (select count(*) from faults where
requesttypenew in (select rtid from requesttype where rtisopportunity=0 and rtisproject=0) and datecleared>start_dts and datecleared<end_dts and dateoccured > getdate()-30)as
'No. of Tickets Closed'
from calendar                                                                     
where start_dts>=getdate()-30 and start_dts<getdate() and start_dts<@enddate /* and weekday_id not in (7,1) */
                                                                           


                                 

