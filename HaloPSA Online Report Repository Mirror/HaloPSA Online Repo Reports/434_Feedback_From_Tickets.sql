      select fbusername as [User],
fbfaultid as [Ticket ID],
 case when fbscore=1 then 'Awesome'
when fbscore=2 then 'Good'
when fbscore=3 then 'OK'
else 'Bad' end  as [Score],fbdate as [Date],
fbcomment as [Comment],
(select uname from uname where unum=clearwhoint) as [Technician] from feedback inner join faults on
fbfaultid=faultid    where fbsubject='Feedback From Ticket'






















