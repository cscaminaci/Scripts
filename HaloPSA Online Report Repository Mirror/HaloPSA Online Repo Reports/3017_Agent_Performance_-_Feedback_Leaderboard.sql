select * , ([Awesome]*2 + [Good]*1 - [Okay]*1 - [Bad]*2) as [Total Points] 
from

(select uname as [Agent]

, (select count(fbid) from feedback where fbscore in (1) and fbfaultid in (select faultid from faults where assignedtoint=unum and datepart(mm,dateoccured)=datepart(mm,getdate()) and datepart(yy,dateoccured)=datepart(yy,getdate()))) as [Awesome]

, (select count(fbid) from feedback where fbscore in (2) and fbfaultid in (select faultid from faults where assignedtoint=unum and datepart(mm,dateoccured)=datepart(mm,getdate()) and datepart(yy,dateoccured)=datepart(yy,getdate()))) as [Good]

, (select count(fbid) from feedback where fbscore in (3) and fbfaultid in (select faultid from faults where assignedtoint=unum and datepart(mm,dateoccured)=datepart(mm,getdate()) and datepart(yy,dateoccured)=datepart(yy,getdate()))) as [Okay]

, (select count(fbid) from feedback where fbscore in (4) and fbfaultid in (select faultid from faults where assignedtoint=unum and datepart(mm,dateoccured)=datepart(mm,getdate()) and datepart(yy,dateoccured)=datepart(yy,getdate()))) as [Bad]


from uname)a where [Awesome]!=0 or [Good]!=0 or [Okay]!=0 or [Bad]!=0
