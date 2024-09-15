select
aareadesc as [Client],
isnull(ih3rdpartyinvoicenumber, 'NOT SYNCED') as [Invoice Number],
ihinvoice_date as [Invoice Date],
ppamount as [Amount]
from prepayhistory 
join area on ppareaint=aarea
left join invoiceheader on ppinvoiceid=ihid
