select isnull(round(sum([Percent])/nullif(count([Percent]),0),0),0) as [Percent] from
(select case when fbscore=1 then 100
            when fbscore=2 then 66
            when fbscore=3 then 33
			when fbscore=4 then 0
			else 0 end as [Percent]
from Feedback where fbdate>getdate()-7
)a
