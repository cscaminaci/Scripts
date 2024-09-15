select aareadesc as [Client],
ldesc as [License/Subscription Name],
idihid as [Invoice Number],
iditem_shortdescription as [Invoice Line Description],
LBillingCycle as [Billing Cycle],
case when ltype=0 then 'License' else 'Subscription' end as [Licence Type],
lstatus as [Licence Status]
from Licence
join area on aarea=larea
left join  InvoiceDetailQuantity on IDQLicenceId=lid
left join invoicedetail on idid=idqidid
where lcount>0  and ldeleted=0

