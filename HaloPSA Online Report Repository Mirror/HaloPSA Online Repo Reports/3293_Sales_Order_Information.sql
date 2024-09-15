     select * ,[Revenue]-[Cost] as [GP] from 
     ( select ohid as 'Order ID'
        , round(sum(OLorderqty*olsellingprice),2) as 'Revenue'
        , round(sum(OLorderqty*OLCostPrice),2) as 'Cost'
        ,(select top 1 faultid from faults where ohfaultid=faultid) as [Ticket ID]
        , aareadesc as [Customer]
        , ohorderdate as 'Order Date'
        , u0.uname as 'Account Manager'
        , u1.uname as 'Assigned Agent'
        , dateoccured as 'Ticket Raised Date'
        , OHorderdate as 'Sales Order Date'
        , OHInvoiceDate as 'Invoice Date'

from orderhead
left JOIN orderline ON ohid = olid
left join faults ON OHfaultid = faultid
JOIN site ON ohsitenum = ssitenum
JOIN area ON sarea = aarea
JOIN uname u0 ON AAccountManagerTech = u0.unum
JOIN uname u1 ON assignedtoint = u1.unum

group by ohid,OHorderdate,u0.uname,u1.uname, dateoccured, OHorderdate, OHInvoiceDate,aareadesc,OHfaultid
        )d


