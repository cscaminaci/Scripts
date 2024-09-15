select
         T.Client
       , T.Category
       , T.Tickets
from
(select 
         T.[Client]
       , T.Category
       , T.Tickets
       , row_number() over(partition by T.[Client] order by T.Tickets desc) as rn
from
(select
         (select aareadesc from area where aarea=areaint) as [Client]
       , category2 as [Category] 
       , count(faultid) as [Tickets]
from faults
where status=9 and datecleared > @startdate and datecleared <@enddate
group by areaint, category2)T) as T
where T.rn<=5 
                 


