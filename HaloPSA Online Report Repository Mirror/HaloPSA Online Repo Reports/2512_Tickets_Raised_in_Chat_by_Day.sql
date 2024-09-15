select 

count (faultid) as [Ticket Count],
convert(nvarchar(10),dateoccured, 126) as [Day]

from faults


inner join faultchat on faults.faultid = faultchat.fcfaultid

group by convert(nvarchar(10),dateoccured, 126) 
