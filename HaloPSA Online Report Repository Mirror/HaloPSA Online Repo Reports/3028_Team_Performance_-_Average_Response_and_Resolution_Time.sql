select
round(avg(fresponsetime),2) as [Avg Response Time],
round(avg(elapsedhrs),2) as [Avg Resolution Time],
convert(nvarchar(7), dateoccured, 126) as [Month],
sectio_ as [Team],
dateoccured as [Date Logged]

from faults 

where fdeleted = 0 
and fmergedintofaultid<1 
and datecreated=dateoccured

group by convert(nvarchar(7), dateoccured, 126), sectio_, dateoccured
