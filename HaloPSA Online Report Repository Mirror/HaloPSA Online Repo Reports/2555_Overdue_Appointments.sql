select apfaultid as 'Ticket ID',
(select aareadesc from area where aarea=aparea) as 'Client',
(select sdesc from site where ssitenum=apsite) as 'Site',
apuser as 'User',
(Select uname from uname where unum=apunum) as 'Agent', 

(select symptom from faults where apid=faultid) as 'Ticket Summary',
(select datediff(day,datecreated,getdate()) from faults where apid=faultid) as 'Ticket Age'

from appointment 

where apdeleted=0 and apenddate<getdate() and apcompletestatus<>0
