select aareadesc as [Client],sum(idnet_amount+idtax_amount) as [Total Invoiced] from invoiceheader
join invoicedetail on ihid = idihid
join area on ihaarea = aarea
where ihchid <> 0
and ihinvoice_date > @startdate
and ihinvoice_date < @enddate
group by aareadesc
