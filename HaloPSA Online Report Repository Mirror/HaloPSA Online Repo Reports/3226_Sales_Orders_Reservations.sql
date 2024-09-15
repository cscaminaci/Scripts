select 
olid as [Order ID],
oldesc as [Order Line],
OLorderqty as [Quantity],
olreservedqty as [Reserved],
OLshippedqty as [Delivered],
olitem as [Item ID]

from orderline where olreservedqty>OLshippedqty
