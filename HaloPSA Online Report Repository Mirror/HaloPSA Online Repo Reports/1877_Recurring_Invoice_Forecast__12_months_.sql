select *,round(isnull([Monthly],0)+isnull([Quarterly],0)+isnull([6-Monthly],0)+isnull([Yearly],0)+isnull([2 Yearly],0),2) as [Total] from (
select  * from (
select  data.first_day_of_month as [Date Formatted],cast(data.month_nm as nvarchar(100))+'-'+cast(data.date_year as nvarchar(100)) as [Date],linetotal,
case
when stdperiod= 1 then 'Weekly'
when stdperiod= 2 then 'Monthly'
when stdperiod= 4 then 'Quarterly'
when stdperiod= 5 then '6-Monthly'
when stdperiod= 3 then 'Yearly'
when stdperiod= 8 then '2 Yearly'
END as billingperiod from 
calendar left join 
(
select  
round(sum(idnet_amount ),2)  Linetotal,
StdPeriod,month_nm,date_year,first_day_of_month
from invoiceheader 
left join invoicedetail on idihid=ihid
left join stdrequest on stdinvoiceid=ihid
join calendar on datepart(DAY,DATEADD(month, DATEDIFF(month, 0, STDNextCreationDate), 0))=datepart(DAY,first_day_of_month) 
and date_id>=STDNextCreationDate  and (date_id<stdenddate or ( (stdenddate is null or year(stdenddate)<2000)))
and date_id>=DATEADD(month, DATEDIFF(month, 0, getdate()), 0) and date_id<dateadd(MONTH,12,getdate()) and first_day_of_month=date_id
where ihid<0 and stdperiod=2
group by StdPeriod,month_nm,date_year,first_day_of_month
union
select  
sum(idnet_amount )  Linetotal,
StdPeriod,month_nm,date_year,first_day_of_month
from invoiceheader 
left join invoicedetail on idihid=ihid
left join stdrequest on stdinvoiceid=ihid
join calendar on datepart(DAY,dateadd(HOUR,13,STDNextCreationDate))=datepart(DAY,date_id) and datepart(MONTH,STDNextCreationDate)=datepart(MONTH,date_id)
and date_id>=STDNextCreationDate  and (date_id<stdenddate or ((stdenddate is null or year(stdenddate)<2000)))
and date_id>=DATEADD(month, DATEDIFF(month, 0, getdate()), 0) and date_id<dateadd(MONTH,12,getdate()) and first_day_of_month=date_id
where ihid<0 and stdperiod=3
group by StdPeriod,month_nm,date_year,first_day_of_month
union
select  
sum(idnet_amount )  Linetotal,
StdPeriod,month_nm,date_year,first_day_of_month
from invoiceheader 
left join invoicedetail on idihid=ihid
left join stdrequest on stdinvoiceid=ihid
join calendar on datepart(DAY,DATEADD(month, DATEDIFF(month, 0, STDNextCreationDate), 0))=datepart(DAY,first_day_of_month) 
and (datepart(MONTH,STDNextCreationDate)=datepart(MONTH,date_id) or datepart(MONTH,dateadd(MONTH,6,STDNextCreationDate))=datepart(MONTH,date_id))
and date_id>=STDNextCreationDate  and (date_id<stdenddate or (stdenddate is null or year(stdenddate)<2000))
and date_id>=DATEADD(month, DATEDIFF(month, 0, getdate()), 0) and date_id<dateadd(MONTH,12,getdate()) and first_day_of_month=date_id
where ihid<0 and stdperiod=5
group by StdPeriod,month_nm,date_year,first_day_of_month
)data
 on data.first_day_of_month=CALENDAR.date_id
 where  CALENDAR.date_id>=DATEADD(month, DATEDIFF(month, 0, getdate()), 0) and CALENDAR.date_id<dateadd(MONTH,12,getdate())
 and date_day=1 )PVT
 PIVOT
(max(linetotal) for billingperiod in (
[Monthly]
,[Quarterly]
,[6-Monthly]
,[Yearly]
,[2 Yearly]
)) outpiv
)b 
