
select *, monday+tuesday+wednesday+thursday+friday as [Total] from (select uname as [Technician], weekday_nm 
from uname LEFT JOIN faults on (uname.unum=faults.clearwhoint and datecleared between 
dateadd(week,datediff(week,0,getdate()),0) AND dateadd(day,5,dateadd(week,datediff(week,0,getdate()),0))) left 
join calendar on cast(datecleared as date)=date_id) src
pivot
(count(weekday_nm) for weekday_nm in ([Monday],[Tuesday],[Wednesday],[Thursday],[Friday]))a


