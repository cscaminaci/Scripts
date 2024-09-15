select
         T.Client
       , T.username as [User]
       , T.Tickets          
from
(select
         T.Client
       , T.username
       , T.Tickets
       , row_number() over(partition by T.[Client] order by T.Tickets desc) as rn
from
(select
         (select aareadesc from area where aarea=areaint) as [Client]
       , username
       , count(faultid) as [Tickets]
from faults
where dateoccured > @startdate and dateoccured < @enddate
group by areaint, username)T) as T
where T.rn<=5

