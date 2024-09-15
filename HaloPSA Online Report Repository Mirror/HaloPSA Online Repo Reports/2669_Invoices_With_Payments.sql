select *
, case when [Amount Due]=0 then 'Paid' when [Amount Due]=[Gross Amount] then 'Unpaid' else 'Partially Paid' end as [Payment Status] 
from (select 
ihid
, ihInvoice_date [Invoice Date]
, ihDue_Date [Due Date]
, aareadesc [Client]
, (select round(sum(idnet_amount),2) from invoicedetail where idihid=ihid) [Net Amount] 
, (select round(sum(idnet_amount+idtax_amount),2) from invoicedetail where idihid=ihid) [Gross Amount]
, isnull((select round(sum(ipamount), 2) from invoicepayment where ipihid=ihid), 0) [Total Paid] 
, isnull((select round(sum(idnet_amount+idtax_amount),2) from invoicedetail where idihid=ihid), 0) - isnull((select round(sum(ipamount), 2) from invoicepayment where ipihid=ihid), 0) [Amount Due]
from invoiceheader
join area on aarea=ihaarea)a


