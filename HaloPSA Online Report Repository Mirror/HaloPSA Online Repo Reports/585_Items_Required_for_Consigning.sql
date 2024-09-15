select iaccountsid as [Stock Code],
idesc as [Item],
iqtyinstock as [Current Stock],
iminstockqty as [Min Stock],
Ireorderqty as [Min Order Qty],
sum(florderqty)-sum(CDQuantity) as [Install Requirement],
sum(florderqty)-sum(CDQuantity)-iqtyinstock as [Stock To Order] 
from item left join faultitem on flitem=iid
left join faults on flid=faultid and status<>9
left join Consignmentheader on CSFaultID=faultid 
left join consignmentdetail on csid=cdcsid and cditem=iid
where (status<>9 or status is null) and  iqtyinstock<iminstockqty
group by iaccountsid,idesc,iqtyinstock,iminstockqty,Ireorderqty

