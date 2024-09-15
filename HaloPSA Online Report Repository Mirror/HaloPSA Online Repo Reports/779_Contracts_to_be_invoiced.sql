select aareadesc as [Client],
case when CHBillingPeriod=1 then 'Weekly' 
                        when CHBillingPeriod=2 then 'Monthly' 
                        when CHBillingPeriod=3 then 'Yearly' 
                        when CHBillingPeriod=4 then 'Quarterly' 
                        when CHBillingPeriod=5 then '6-Monthly' 
                        when CHBillingPeriod=6 then '5-Yearly' 
                        when CHBillingPeriod=7 then '3-Yearly' 
                        when CHBillingPeriod=8 then '2-Yearly' 
                        when CHBillingPeriod=9 then '4-Yearly' else 'Weekly' end as [Period],
chperiodchargeamount as [Rate],
chperiodicinvoicenextdate as [Next Invoice Date],
chcontractref as [Contract Reference],
fvalue as [Billing Type],
(select sum (isnull(dccontractvaluecurrent,0)) from devicecontract where chid=dccontractid) as [Total Asset Value]
from contractheader 
join area on aarea=charea
join lookup on fid=28 and fcode=chbillingdescription
