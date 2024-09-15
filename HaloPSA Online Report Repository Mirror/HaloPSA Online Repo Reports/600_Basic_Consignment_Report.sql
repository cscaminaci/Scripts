select csid as [Consignment ID],
csdate as [Date],
sdesc as [Site],
idesc as [Item],
cdquantity as [Quantity],
cdcostprice as [Cost Price]
 from consignmentheader 
 join consignmentdetail on csid=cdcsid
 join item on iid=cditem
 join site on ssitenum=case when csfaultid>0 then (select sitenumber from faults where csfaultid=faultid) 
 else (select ohsitenum from orderhead where ohid=csohid) end

