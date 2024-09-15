select * 
, round(sum(isnull([Non-Taxable Revenue],0)+isnull([Taxable Revenue],0)),2) [Gross Revenue]
, round(sum(isnull([Non-Taxable Revenue],0)+isnull([Taxable Revenue],0)+isnull([Gross Sales Tax],0)),2) [Invoice Total]

from
(select aareadesc [Customer]
, ihid [Invoice ID]
, ihinvoice_date [Invoice Date]
, round(sum(isnull(ntrevenue,0)),2) [Non-Taxable Revenue]
, round(sum(isnull(trevenue,0)),2) [Taxable Revenue]
, round(sum(isnull(salestax,0)),2) [Gross Sales Tax]
from area
left join invoiceheader on ihaarea=aarea
left join invoicedetail on idihid=ihid

outer apply (select idnet_amount ntrevenue where IDTax_Amount=0)ntr
outer apply (select idnet_amount trevenue where IDTax_Amount>0)tr
outer apply (select idtax_amount salestax where IDTax_Amount>0)st 

where ihid>0
group by aareadesc, aarea, ihid, ihinvoice_date) a


group by a.[Customer], a.[Invoice ID], a.[Invoice Date], a.[Non-Taxable Revenue], a.[Taxable Revenue], a.[Gross Sales Tax]
