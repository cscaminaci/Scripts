
select top 100 percent
[Customer],
[Contract Type],
[Date],
date_id,
round([Revenue],2) as [Revenue],
round(sum([Cost]),2) as [Labour Cost],
round([Recurring Cost],2) as [Recurring Cost],
isnull(round((([Revenue]-(sum([Cost])+[Recurring Cost]))/nullif([Revenue],0))*100,2),0) as [Profitability (%)]
from (
select top 100 percent
       aareadesc as [Customer]
    , fvalue as [Contract Type]
       , cast(date_year as nvarchar(4))+' '+month_nm as [Date]
    , date_id
       , (select sum(IDQty_Order*IDUnit_Price) from INVOICEDETAIL where IdIHid=IHid) as [Revenue]
       , isnull(timetaken*ucostprice,0) as  [Cost]
       ,(select sum(IDQty_Order*IDUnit_Cost) from INVOICEDETAIL where IdIHid=IHid) as [Recurring Cost]
from calendar
join area on 1=1
left join contractheader on charea=aarea
join invoiceheader on ihid<0 and ihchid=chid
left join faults on aarea=areaint and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) and fcontractid>0
left join actions on actions.faultid=faults.faultid and datepart(MONTH,date_id)=datepart(MONTH,whe_) and datepart(year,date_id)=datepart(year,whe_)
left join uname on whoagentid=unum
left join lookup on fid=28 and chbillingdescription=fcode
where chstatus=3 and date_day=1 and date_id>getdate()-366 and date_id<getdate() and date_id>chstartdate
order by date_id
)b
group by [Customer],[Contract Type],[Date],[Revenue],date_id,[Recurring Cost]
order by  [Customer],date_id

