select fldesc as [Item],
flid as [Ticket ID],
uname as [Technician],
flsellingprice as [Price],
florderqty as [Quantity],
flsellingprice*florderqty as [Total],
umaxorderamount as [Order Limit]
 from faultitem join faults on faultid=flid join uname on unum=assignedtoint
where umaxorderamount<(select sum(flsellingprice*florderqty) from faultitem b where flid=b.flid) and            
      umaxorderamount>0

