select * 
,round(isnull([Contract Profit],0)+isnull([Ad-hoc Invoices],0)-isnull([Agent Costs],0),2) as [Profitability]

from (

select aareadesc as [Client]
,round((select sum(IDQty_Order*(IDUnit_Price-IDUnit_Cost)) from INVOICEDETAIL where IdIHid in (select ihid from INVOICEHEADER where aarea=IHaarea and ihid<0)) * datediff(month,@startdate,@enddate),2) as [Contract Profit]

,round((select sum(IDQty_Order*(IDUnit_Price-IDUnit_Cost)) from INVOICEDETAIL where IdIHid in (select ihid from INVOICEHEADER where aarea=IHaarea and IHchid=0 and IHInvoice_Date>@startdate and IHInvoice_Date<@enddate)),2) as [Ad-hoc Invoices]

,round((select sum([Time]*[Rate]) as [Cost] from (
select aarea
,unum
,(select sum(timetaken) from actions join faults on faults.faultid=actions.faultid where who=uname and Areaint=aarea and FDeleted=0 and Whe_>@startdate and Whe_<@enddate) as [Time]
,ucostprice as [Rate]
from uname,area)d where a.Aarea=d.Aarea group by d.Aarea),2) as [Agent Costs]
from AREA a
)x
