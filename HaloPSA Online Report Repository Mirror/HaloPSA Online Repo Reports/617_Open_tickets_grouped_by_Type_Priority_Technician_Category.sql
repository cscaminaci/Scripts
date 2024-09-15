select
rtdesc as [Request Type], 
Category2 as [Service Request Category],
pdesc as [Ticket Priority],
uname as [Assigned To],
count(faultid) as [Total]
from faults
join requesttype on rtid=requesttypenew
join uname on assignedtoint=unum
join Policy on ppolicy=seriousness and Pslaid=slaid
where status<>9
group by rtdesc,category2,pdesc,uname

