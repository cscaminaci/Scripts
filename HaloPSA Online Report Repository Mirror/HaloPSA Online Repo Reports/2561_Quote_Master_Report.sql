select *, 

case when a.[Recurring True/False] = 'false' then [Total] else '' end as [Total One-Off Revenue],

case when a.[Recurring True/False] = 'false' then [Total Cost] else '' end as [Total One-Off Cost],

case when a.[Recurring True/False] = 'false' then [Total GP] else '' end as [Total One-Off GP],

case when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Monthly' then round(([Total] * 12),2)

when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Annual' then round([Total],2)

else '' 

end as [Total Recurring Revenue]

,

case when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Monthly' then round(([Total Cost] * 12),2)

when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Annual' then round([Total Cost],2)

else '' 

end as [Total Recurring Cost]

,

case when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Monthly' then round(([Total GP] * 12),2)

when a.[Recurring True/False] = 'true' and [Monthly/Annual] = 'Annual' then round([Total GP],2)

else '' 

end as [Total GP Recurring]

from (

select 
QHDate as [Quote Date]
,qhfaultid as [Ticket ID]
,cdesc as [Supplier]
,CASE
    WHEN idesc is not null THEN idesc
    ELSE qddesc
END as [Item Description]
,idesc2 as [SKU]
,QDPrice as [Price]
,qhstatus as [Status ID]
,QDCostPrice as [Cost]
,QDQuantity as [Quantity]
,aareadesc as [Client]
,uname as [Assigned Salesperson]
,IIsRecurringItem as [Recurring?]
,case when idefaultbillingperiod=2 and IIsRecurringItem=1 then 'Monthly'
when idefaultbillingperiod=3 and IIsRecurringItem=1 then 'Annual' else 'Not Recurring' end as [Monthly/Annual]
,case when IIsRecurringItem=1 then'True' else 'False' end as [Recurring True/False]
,INominalCode as [Accounts Code (Sales)]
,round(sum(QDQuantity*QDPrice),2) as [Total]
,round(sum(QDQuantity*qdcostprice),2) as [Total Cost]
,round(sum(QDQuantity*QDPrice) - sum(QDQuantity*qdcostprice),2) as [Total GP]
,qhtitle as [Quote Reference]
,(select top 1 whe_ from actions where faults.faultid=actions.faultid and actionstatusafter=22) as [Date/Time Quote Accepted]
,	datecleared as [Date Opp was closed]
,aareadesc as [Customer]

from faults

join QUOTATIONHEADER on qhfaultid=faultid
join QUOTATIONDETAIL on qhid=qdqhid
left join orderhead on ohqhid=qhid
left join orderline on qdid=olquotelineID
left join company on qdsupplier=cnum
left join item on qditemid=iid
left join uname on unum=assignedtoint
left join area on aarea=areaint

where fdeleted=0 and qhstatus=1

group by faultid,datecleared,qhid,qddesc,qhdate,qhtitle,qhfaultid,qhstatus,aareadesc,uname,cdesc,idesc,idesc2, idefaultbillingperiod,INominalCode,QDQuantity,QDPrice,QDCostPrice,IIsRecurringItem, iid 
)A
