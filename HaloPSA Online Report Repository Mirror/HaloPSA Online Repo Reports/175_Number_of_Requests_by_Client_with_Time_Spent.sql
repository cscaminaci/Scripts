select
sdesc as 'Site',
aareadesc as 'Client',
(select count(faultid) from faults where ssitenum=sitenumber and dateoccured > @startdate and dateoccured < 
@enddate)'LoggedRequests',
(select count(faultid) from faults where ssitenum=sitenumber and Status =9 and dateoccured > @startdate and dateoccured < 
@enddate)'ClosedRequests',
SUM(timetaken) as 'WorkingTime',                    
SUM(actions.nonbilltime) as 'NonBillTime'
from site join Area on aarea=sarea join Faults on Ssitenum = sitenumber join ACTIONS on Faults.Faultid = ACTIONS.faultid
where dateoccured > @startdate
and dateoccured < @enddate
group by ssitenum,sdesc,aareadesc


