select ihid as [Invoice Number]
,aareadesc as [Customer]
,IHdateCreated as [Date Created]
,IDItem_ShortDescription as [Item Name]
,IDUnit_Price as [Unit Price]
,IDQty_Order as [Quantity]
,IDUnit_Price*IDQty_Order as [Total]
,IDTax_Amount as [Tax]
,IDUnit_Price*IDQty_Order+IDTax_Amount as [Total inc Tax]


from INVOICEDETAIL
join INVOICEHEADER on ihid=IdIHid
join area on aarea=IHaarea
where IHid>0

