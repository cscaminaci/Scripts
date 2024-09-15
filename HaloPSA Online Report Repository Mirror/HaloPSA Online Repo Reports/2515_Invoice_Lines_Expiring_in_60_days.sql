select 
aareadesc as [Customer],
IDItem_ShortDescription as [Item/Product],
IDNet_Amount as [Net Amount],
cast(IDenddate as date) as [End Date]
from invoicedetail
left join invoiceheader on idihid=ihid
left join area on ihaarea=aarea
where idisInactive=0 and IDenddate<getdate()+60 and IDenddate>365
