Select [Client Name],[Ticket ID],[Summary],[Charge Rate],[Sunday],[Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday]
FROM
(select 
weekday_nm as [Date],
aareadesc as [Client Name],
faults.faultid as [Ticket ID],
symptom as [Summary],
round(isnull(sum(timetaken),0),2) as [Time], 
(select fvalue from lookup where fid=17 and fcode=actioncode+1) as [Charge Rate]
from actions
join calendar on cast(whe_ as date)=date_id
join faults on faults.faultid=actions.faultid
join requesttype on rtid=requesttypenew
join area on aarea=areaint

where date_id between (select top 1 date_id from calendar where weekday_id=1 and date_id<=getdate() order by date_id desc)
                 and dateadd(day,7,(select top 1 date_id from calendar where weekday_id=1 and date_id<=getdate() order by date_id desc))

group by aareadesc,faults.faultid,actioncode,symptom,date_id,weekday_nm) as P
PIVOT
(max([Time]) for [Date] in
([Sunday],[Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday])
) AS PIVOTTABLE

