select FBusername as [Client User],
fbfaultid as [Ticket ID],
sectio_ as [Team],
Compliance=case when fexcludefromsla='true' then 'Excluded' when fixbydate<datecleared then 
'Outside'  when datecleared<fixbydate then 'Inside' else 'Open' end,

case when FBscore=1 then 'Awesome'
when FBscore=2 then 'Good'
when FBscore=3 then 'Ok'
when fbscore=4 then 'Bad'
end as [Rating],

fbDate as [Date],
fbcomment as [Comment],
uname as [Agent],
fbscore 

from feedback 
inner join faults on fbfaultid=faultid
inner join uname on unum=assignedtoint
where uisdisabled = 0
and fdeleted=0
and fixbydate<datecleared
