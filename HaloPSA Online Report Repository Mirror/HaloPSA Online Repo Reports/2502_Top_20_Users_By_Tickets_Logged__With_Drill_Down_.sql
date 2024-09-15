select
faultid as [Ticket ID],
symptom as [Summary],
dateoccured as [Date Opened],
username as [User],
sectio_ as [Team],
(select uname from uname where assignedtoint=unum) as [Assigned Agent],
(select tstatusdesc from tstatus where tstatus=status) as [Status],
case when category2 like '%>%' then left(category2,(charindex('>',category2)-1)) 
else category2 end as [Category]

from faults f

where username IN (select top 20 abc.[user] as username from (select count(faultid) Total, username as [user] 

from faults abc 

where dateoccured>@startdate and dateoccured<@enddate and username not like '%User%' and username not like '%@%' and username != '' and fdeleted=fmergedintofaultid and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)

group by abc.username)abc

order by abc.total desc

) and dateoccured>@startdate and dateoccured<@enddate and username not like '%User%' and username not like '%@%' and username != '' and fdeleted=fmergedintofaultid and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
