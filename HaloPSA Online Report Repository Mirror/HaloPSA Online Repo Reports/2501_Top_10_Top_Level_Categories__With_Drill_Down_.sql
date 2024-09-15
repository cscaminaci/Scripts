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

where case when category2 like '%>%' then left(category2,(charindex('>',category2)-1)) 
else category2 end IN (select top 10 abc.categorycount category from (select count(faultid) Total, case when abc.category2 like '%>%' then left(category2,(charindex('>',category2)-1)) else category2 end as categorycount 

from faults abc 

where dateoccured>@startdate and dateoccured<@enddate and category2 not like 'Example%' and category2 != '' and fdeleted=fmergedintofaultid and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)

group by case when abc.category2 like '%>%' then left(category2,(charindex('>',category2)-1)) else category2 end)abc

order by abc.total desc

) and dateoccured>@startdate and dateoccured<@enddate and category2 not like 'Example%' and category2 != '' and fdeleted=fmergedintofaultid and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0)
