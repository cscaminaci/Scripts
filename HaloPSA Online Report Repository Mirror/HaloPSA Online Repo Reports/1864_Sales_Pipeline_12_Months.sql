select 
sum(foppvalue) as [Total],
first_day_of_month as [OrderDate],
left(month_nm ,3)+' - '+cast(date_year as nvarchar(30)) as [Date]
from calendar 
left join faults on fopptargetdate>=date_id and fopptargetdate<dateadd(day,1,date_id) and  foppvalue>0
where  date_id>DATEADD(month, DATEDIFF(month, 0, getdate()), 0) and date_id<DATEADD(month, DATEDIFF(month, 0, getdate())+12, 0)
group by first_day_of_month,month_nm,date_year 
