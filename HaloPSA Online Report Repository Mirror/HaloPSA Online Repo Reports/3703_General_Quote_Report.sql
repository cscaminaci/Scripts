select 

    qhid as [Quote ID]
,qhtitle as [Quote Reference]
,aareadesc as [Customer]
,uname as [Assigned Salesperson]
,
round((
select SUM(quotationdetail.qdprice*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Revenue]
,
round((
select SUM(quotationdetail.qdcostprice*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Cost]
,
round((
select SUM((quotationdetail.qdprice - quotationdetail.qdcostprice)*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Profit]

,CONVERT(VARCHAR(7), FOppTargetDate, 23) AS  [Target Sale Close Date]

,QHDate as [Quote Date]

,(select top 1 whe_ from actions where faults.faultid=actions.faultid and actionstatusafter=18) as [Date/Time Quote Approved]
from faults
join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
left join area on aarea=areaint
left join uname on unum=assignedtoint
left join calendar on fopptargetdate>=date_id 
where qhid in (select OHQHID from orderhead)

group by qhid,FOppTargetDate,uname,qhdate,qhtitle,faultid,aareadesc,qhstatus

