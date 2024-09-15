select *,
RIGHT('0' + CAST (FLOOR([Time]) AS VARCHAR), 2) + ':' + 
RIGHT('0' + CAST(FLOOR(((([Time] * 3600) % 3600) / 60)) AS VARCHAR), 2) + ':' + 
RIGHT('0' + CAST (FLOOR(([Time] * 3600) % 60) AS VARCHAR), 2) as [Time Spent]
from (
select 
faults.faultid as [Ticket ID],
whe_ as [Date],
uname as [Technician],
category2 as [Category],
substring(note,0,200) as [Note],
convert(decimal(7,4),(timetaken+timetakenadjusted)) as [Time]
from faults
join actions on actions.faultid=faults.faultid
join uname on unum=whoagentid
where actioninvoicenumber=$InvoiceId)n

