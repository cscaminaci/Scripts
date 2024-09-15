select date_id as [ID],month_nm as [Month],count(faultid) as Total,category2 as [Category]
from calendar join faults on dateoccured>first_day_of_month and dateoccured<last_day_of_month 
where date_day=1 
and start_dts<cast(dateadd(month,-1,getdate()) as date) 
and start_dts>cast(dateadd(month,-13,getdate()) as date)
and category2<>''
group by category2,month_nm,start_dts,date_id





