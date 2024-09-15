select cdesc as [Supplier]
,count(*) as [Total Tickets]
,COUNT(nullif(Suppresponsestate,'O')) as [Reponse SLA Met]
,round(COUNT(nullif(Suppresponsestate,'O'))/nullif(COUNT(*),0),1)*100 as [Reponse SLA Met %]
,COUNT(nullif(Suppresponsestate,'I')) as [Response SLAs Missed]
,round(COUNT(nullif(Suppresponsestate,'I'))/nullif(COUNT(*),0),1)*100 as [Response SLAs Missed%]
,sum(case when Suppresponsestate is null then 1 else 0 end) as [Not Responded]
,ROUND(sum(case when Suppresponsestate is null then 1 else 0 end)/nullif(COUNT(*),0),1)*100 as [Not Responded %]
,ROUND(avg(SuppResponseTime),2) as [Avg Response (Hrs)]
,COUNT(nullif(suppbreachfixbysent,0)) as [SLA Breach Emails Sent]
from company join FAULTS on cnum = supplier and supplier>1
where datecleared between @startdate and @enddate and fdeleted=0 and fmergedintofaultid=0
group by cdesc
