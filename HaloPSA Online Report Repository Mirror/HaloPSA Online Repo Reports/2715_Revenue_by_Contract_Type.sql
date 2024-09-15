select * from (
select aareadesc as [Customer]
,aarea as [IDCustomer]
,IHInvoice_Date as [Datetime]
,format(IHInvoice_Date,'yyyy MMMM') as [Date]
,IDItem_ShortDescription as [Description]
,cast(IDNet_Amount as money) as [Revenue]
,cast(isnull(case when IDFaultid>0 then round(timetaken*ucostPrice,2) else IDUnit_Cost*IDQty_Order end,0) as money) as [Cost]
,cast(IDNet_Amount-(IDUnit_Cost*IDQty_Order) as money) as [Profit]
,(select fvalue from lookup where fid=28 and fcode=(select chbillingdescription from contractheader where chid=(select c.ihchid from invoiceheader c where INVOICEHEADER.IHrecurringInvoiceId=ihid))) as [Contract Ref]
,(select fvalue from lookup where fid=33 and fcode=acustomertype) as [Customer Type]
from INVOICEHEADER
join invoicedetail on ihid=IdIHid
left join area on IHaarea=Aarea
left join actions on actions.faultid=IDFaultid and Whe_=IDLineActionDate
left join uname on whoagentid=Unum
where ihid>0)d
where [Contract Ref] is not null
