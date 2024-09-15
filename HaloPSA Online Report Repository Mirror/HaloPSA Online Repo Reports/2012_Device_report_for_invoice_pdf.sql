select tdesc as [Asset Type],
dinvno as [Serial Number],
(select count(faultid) from faults where devicenumber=ddevnum and devsite=dsite and dateoccured>dateadd(YEAR,-1,ihinvoice_date)
and dateoccured<ihinvoice_date ) as [Tickets this period]
from xtype
join device on dtype=ttypenum
join site on dsite=ssitenum
join invoiceheader on ihaarea=sarea and ihid=$invoiceid

