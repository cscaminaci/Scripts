select (select aareadesc from area where ihaarea=aarea) as [Client],
IHInvoicenumber as [NHD Invoice ID],
IHInvoice_Date as [Invoice Date],
IDItem_shortdescription as [Item],
IDQty_order as [Quantity],
IDUnit_price as [Unit Price],
IDNet_Amount as [Net Price],
IDTax_Amount as [Tax Amount],
cast(IDTax_rate as nvarchar(5))+'%' as [Tax Rate],
case when id_itemid=1 then 'Ad-Hoc' else 'In System' end as [Ad-Hoc/In-System]
 from invoiceheader join invoicedetail on ihid=idihid





