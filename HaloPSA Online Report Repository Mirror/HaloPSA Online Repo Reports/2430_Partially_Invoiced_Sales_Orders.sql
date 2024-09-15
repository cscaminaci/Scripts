
select ohid as [SalesOrderNumber]
,aareadesc as [Customer]
,sdesc as [Site]
,ohnote as [SalesOrderNote]
,tstatusdesc as [Status] 
,(select sum(ihpercent) from invoiceheader where ihid=OHInvoiceNumber) as [Invoiced]

from orderhead

left join site on ohsitenum=ssitenum
left join area on aarea=sarea
left join tstatus on ohstatus=tstatus
left join invoiceheader on ihid=OHInvoiceNumber
where ihpercent<100 or ihpercent is null
