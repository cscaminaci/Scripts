select 
aareadesc as [Client],
chcontractref as [Contract Reference],
actions.faultid as [Ticket Number],
whe_ as [When],
note as [Note],
(actionchargehours)*60 as [Time Logged],
cast(actionchargeamount as money) as [Price],
cast(((actionchargehours) * ucostprice) as money) as [Cost],
cast(actionchargeamount - ((actionchargehours) * ucostprice) as money) as [Profit],
who as [Agent]
from actions 
join faults on faults.faultid=actions.faultid
join area on aarea=areaint
join contractheader on charea=aarea
join uname on who=uname
where (actionchargehours)>0 and actioncontractid<>0 and actisbillable=1
