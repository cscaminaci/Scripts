select * 
,cast([Rate]*[Billable Time] as money) as [Billable $]
from (

select uname as [Agent]
,actions.Faultid as [Ticket ID]
,Symptom as [Summary]
,aareadesc as [Customer]
,aarea as [IDCustomer]
,round(sum(isnull(timetaken,0)+isnull(timetakenAdjusted,0)),2) as [Billable Time]
,(select fvalue from lookup where fid=17 and fcode=actioncode+1) as [Charge Type]
,case when (select crrate from CHARGERATE where Aarea=CRarea and ActionCode+1=CRchargeid)>0 then (select crrate from CHARGERATE where Aarea=CRarea and ActionCode+1=CRchargeid)
else (select crrate from CHARGERATE where CRarea=0 and ActionCode+1=CRchargeid) end as [Rate]
from actions
join faults on actions.faultid=faults.Faultid
join area on Aarea=Areaint
join uname on who=uname 
join requesttype on requesttypenew=rtid 
where actions.ActionInvoiceNumber is null 
and (actionbillingplanid=-2 or (actionbillingplanid=-1 and ActionChargeHours>0))
and FDeleted=0 
and rtisproject=0
group by uname,actions.Faultid,Symptom,aareadesc,ActionCode,Aarea
)d
