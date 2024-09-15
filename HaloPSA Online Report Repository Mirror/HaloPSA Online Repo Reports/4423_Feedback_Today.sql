select 
case when fbscore=1 then 'Awesome'
when fbscore=2 then 'Great'
when fbscore=3 then 'Good'
when fbscore=4 then 'Bad'
else 'Bad' end as [Score],
round(count(fbid) /cast((select count(fbid) from feedback where fbdate>=cast(getdate() as date) and fbdate<cast(getdate()+1 as date)) as float)*100,1) as [Percentage]
from feedback where fbdate>=cast(getdate() as date) and fbdate<cast(getdate()+1 as date) group by fbscore





