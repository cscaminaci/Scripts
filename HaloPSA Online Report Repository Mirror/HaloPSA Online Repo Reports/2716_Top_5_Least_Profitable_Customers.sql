select top 5 * from(

select aareadesc as [Customer]
,aarea as [IDCustomer]
,(select sum(cast(IDNet_Amount as money)) from INVOICEHEADER join invoicedetail on ihid=IdIHid where IHaarea=Aarea and ihid>0 and IHInvoice_Date>@startdate and IHInvoice_Date<@enddate) as [Revenue]
,(select sum(cast(isnull(case when IDFaultid>0 then round(timetaken*ucostPrice,2) else IDUnit_Cost*IDQty_Order end,0) as money)) from INVOICEHEADER join invoicedetail on ihid=IdIHid left join actions on actions.faultid=IDFaultid and Whe_=IDLineActionDate left join uname on whoagentid=Unum where IHaarea=Aarea and ihid>0 and IHInvoice_Date>@startdate and IHInvoice_Date<@enddate) as [Cost]
,(select sum(cast(IDNet_Amount-(IDUnit_Cost*IDQty_Order) as money)) from INVOICEHEADER join invoicedetail on ihid=IdIHid where IHaarea=Aarea and ihid>0 and IHInvoice_Date>@startdate and IHInvoice_Date<@enddate) as [Profit]

from area
)d 
where [Revenue]>0
order by [Profit] asc
