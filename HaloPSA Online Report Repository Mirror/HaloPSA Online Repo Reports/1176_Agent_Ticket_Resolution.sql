select * from 
(select uname as [Agent]
, (select count(faultid) from faults where clearwhoint=unum and datecleared between @startdate and @enddate and fdeleted=0 and fmergedintofaultid<1
and requesttypenew in (120,1,60)) as [TicketsResolved]
from uname 
where unum!=1)a where [TicketsResolved]!=0

