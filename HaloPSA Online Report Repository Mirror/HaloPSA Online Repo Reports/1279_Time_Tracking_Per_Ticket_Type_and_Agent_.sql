select who as [Agent]
,f.faultid as [Ticket ID]
,fvalue as [Charge Rate]
,cast(round(floor(sum(timetaken)) + ((sum(timetaken) - floor(sum(timetaken)))*0.6),2)as float) as [Time (hh.mm)]

from faults f
join actions a on a.faultid=f.faultid
join lookup on fcode = a.ActionCode+1 where fid=17
and fdeleted=0 and who in (select uname from uname)
group by who,f.faultid,fvalue
