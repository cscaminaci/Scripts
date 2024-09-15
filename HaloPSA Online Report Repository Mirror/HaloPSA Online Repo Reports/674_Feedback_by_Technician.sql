select count(ticket_id)as Count, Score, Technician from
(
  select 
  fbfaultid as [Ticket_ID],
  case when fbscore=1 then 'Awesome' when fbscore=2 then 'Good' when fbscore=3 then 'OK' else 'Bad' end  as [Score],
  (select uname from uname where unum=assignedtoint) as [Technician]
  from feedback inner join faults on  fbfaultid=faultid
  where fbsubject='Feedback From Ticket' and fbdate>@startdate and fbdate<@enddate
)a
group by technician, Score



