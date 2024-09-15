select 
count(id) as [Count of Re-Assigns], 
rtlfaultid as [Ticket ID],
symptom as [Summary],
sectio_ as [Team],
rtdesc as [Ticket Type]
from resourcetimelog
join faults on rtlfaultid=faultid
join requesttype on rtid=requesttypenew
where dateoccured between @startdate and @enddate
group by rtlfaultid,symptom,sectio_,rtdesc
