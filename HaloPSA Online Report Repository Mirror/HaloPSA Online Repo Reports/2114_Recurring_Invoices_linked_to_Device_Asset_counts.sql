select *,(select count (*) from device where dtype=[Device Type ID] and dsite in (select ssitenum from site where sarea = [Customer ID])) as [Actual Device Qty] from (
select 
aareadesc as [Customer],
aarea as [Customer ID],
ihid as [Recurring Invoice ID],
tdesc as [Device Type],
ttypenum as [Device Type ID],
iditem_shortdescription as [Invoice Description],
sum(idqty_order) as [Current Invoice Qty]
 from InvoiceDetailQuantity
join xtype on IDQTypeId=ttypenum 
join INVOICEDETAIL on idid=idqidid
join invoiceheader on ihid=idihid
join area on aarea=ihaarea
where IDQKind=3
group by aareadesc,aarea,ihid,tdesc,ttypenum,iditem_shortdescription)b

