select 
format(date_id,'MM/yy') as [Month]
,rtdesc as [Ticket Type]
,count(*) as [Count]
from calendar 
join faults on convert(date,datecleared)=date_id
join requesttype on rtid=requesttypenew
where year(date_id)=year(@startdate)
group by format(date_id,'MM/yy'), rtdesc
