select
idesc as [Item],
iaccountsid as [Accounts Code],
idesc2 as [Supplier Code],
(select sdesc from site where ssitenum=ISHlocation) as [Location],
sum(ishquantityin) as [Quantity]
from item 
JOIN itemstockhistory on ishiid=iid 
left join itemstock on isid=ishitemstockid
WHERE ishdate <@enddate
GROUP BY idesc, Iaccountsid, idesc2, ISHlocation
