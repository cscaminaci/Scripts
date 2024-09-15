select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-12,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)c
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-11,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)d
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-10,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)e
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-9,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-8,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-7,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-6,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-5,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-4,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-3,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-2,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b
union
select * from
(select top 5 month_nm as [Month],count(faultid) as Total,category2 as [Category],date_id as [Order] 
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where 
start_dts=cast(dateadd(month,-1,getdate()) as date) 
and category2<>''
group by category2,month_nm,start_dts,date_id order by total desc)b



