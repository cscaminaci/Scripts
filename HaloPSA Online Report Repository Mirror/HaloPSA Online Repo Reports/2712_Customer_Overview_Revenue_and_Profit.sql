select aareadesc as [Customer]
,aarea as [IDCustomer]
,(select fvalue from lookup where fid=28 and fcode=(select chbillingdescription from contractheader where chid=(select c.ihchid from invoiceheader c where INVOICEHEADER.IHrecurringInvoiceId=ihid))) as [Contract Ref]
,(select fvalue from lookup where fid=33 and fcode=acustomertype) as [Customer Type]
,sum(cast(IDNet_Amount as money)) as [Revenue]
,sum(cast(isnull(case when IDFaultid>0 then round(timetaken*ucostPrice,2) else IDUnit_Cost*IDQty_Order end,0) as money)) as [Cost]
,sum(cast(IDNet_Amount-(IDUnit_Cost*IDQty_Order) as money)) as [Profit]
,case when sum(cast(IDNet_Amount-(IDUnit_Cost*IDQty_Order) as money))>0 then 100 else 0 end as [Profitable Customer (100=yes, 0=no)]
from INVOICEHEADER
join invoicedetail on ihid=IdIHid
left join area on IHaarea=Aarea
left join actions on actions.faultid=IDFaultid and Whe_=IDLineActionDate
left join uname on whoagentid=Unum
where ihid>0
and IHInvoice_Date>@startdate 
and IHInvoice_Date<@enddate

group by aareadesc,aarea,IHrecurringInvoiceId,acustomertype
