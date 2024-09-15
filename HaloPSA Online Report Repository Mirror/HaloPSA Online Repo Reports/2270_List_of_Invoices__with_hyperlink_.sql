select ihid as [Invoice Number]
,aareadesc as [Customer]
,IHdateCreated as [Date Created]
,IDItem_ShortDescription as [Item Name]
,IDUnit_Price as [Unit Price]
,IDQty_Order as [Quantity]
,IDUnit_Price*IDQty_Order as [Total exc Tax]
,IDTax_Amount as [Tax]
,IDUnit_Price*IDQty_Order+IDTax_Amount as [Total inc Tax]
,(select LogoutRedirectUri from NHD_IDENTITY_Application where ClientId='24fe0a24-85d5-46d4-b9c6-721e23f25843') as [URL] 
,ihdue_date as [Due Date]
,datediff(day,ihdue_date ,getdate()) as [Days overdue]
,ihdatesent as [Date Sent]
,ihdatepaid as [Date Paid]
from INVOICEDETAIL
join INVOICEHEADER on ihid=IdIHid
join area on aarea=IHaarea
where IHid>0

