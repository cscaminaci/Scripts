select 
	  count(ofaultid) as [OpenTickets]
	, count(nhfaultid) as [OpenTicketsExcl.Hold]
from
	  faults 
LEFT JOIN
(select faultid nhfaultid from faults where status not in (8,9) and requesttypenew in (select rtid from requesttype where rtisproject=0 and RTIsOpportunity=0 and fdeleted=0) and FSLAonhold!=1)noHold on faultid=nhfaultid
LEFT JOIN
(select faultid ofaultid from faults where status not in (8,9) and requesttypenew in (select rtid from requesttype where rtisproject=0 and RTIsOpportunity=0) and fdeleted=0)o on faultid=ofaultid
