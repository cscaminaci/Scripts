select * from (
    (select
'*NOT FOUND*' as [Client],
AValue as [User],
apkid1 as [User ID],
aactoutcome as [Action],
ADate as [Date],
(SELECT uname FROM uname WHERE aunum = unum) as [Agent]
from audit
where atablename='users' and ADate between @startdate and @enddate)

UNION

(select
aareadesc as [Client],
uusername as [User],
uid as [User ID],
'User Created' as [Action],
udatecreated as [Date],
null as [Agent]
from users join site on Usite=ssitenum join area on aarea=Sarea where udatecreated between @startdate and @enddate)
)a
