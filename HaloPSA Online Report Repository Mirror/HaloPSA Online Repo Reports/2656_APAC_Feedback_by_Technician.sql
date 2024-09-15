select Ticket, awesome,good,ok,bad, Technician from
(
  select 

faultid as 'Ticket',

  case when fbscore=1 then '1' else '0' end  as [Awesome],

case when fbscore=2 then '1' else '0'  end  as [Good],

case  when fbscore=3 then '1' else '0'  end  as [OK],

case when fbscore=4 then '1' else '0'  end  as [Bad],
 

 (select uname from uname where unum=assignedtoint) as [Technician]
  from feedback inner join faults on  fbfaultid=faultid
  where fbsubject='Feedback From Ticket' and fbdate>@startdate and fbdate<@enddate
)a
group by technician,awesome,good,ok,bad, ticket



