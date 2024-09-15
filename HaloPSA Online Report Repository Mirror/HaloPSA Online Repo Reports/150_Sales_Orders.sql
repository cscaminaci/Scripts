        select olid as 'Order ID', oldesc as 'Item Description' , olorderqty as 'Quantity',
( select ibaseprice from item where iid=olitem)'List Price', olsellingprice as 'Sales Price', (select 
ohorderdate from 
orderhead where olid=ohid) as 'Order Date'
from orderline


