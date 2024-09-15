SELECT

uusername AS [User],
(select sdesc from site where usite=ssitenum) as [Site],
(select  aareadesc from area where aarea=(select sarea from site where usite=ssitenum)) as [Customer],
count(faultid) AS [Number of Tickets Logged],
(select SUM(timetaken) from actions where faults.faultid=actions.faultid and whe_ > @startdate AND whe_ < @enddate) as [Sum of time taken],
AVG(fresponsetime) as [Average Response Time]
,left(CAST(CONVERT(VARCHAR,DATEADD(SECOND, (select SUM(timetaken) from actions where faults.faultid=actions.faultid and whe_ > @startdate AND whe_ < @enddate) * 3600, 0),108) AS TIME), 5) as [Sum of time taken HH:MM]
,left(CAST(CONVERT(VARCHAR,DATEADD(SECOND, AVG(fresponsetime) * 3600, 0),108) AS TIME), 5) as [Average Response Time HH:MM]

FROM faults

left join users on uid=userid

WHERE
dateoccured > @startdate AND dateoccured < @enddate
AND uusername NOT LIKE '%General User%'

AND fdeleted = fmergedintofaultid
GROUP BY

uusername,faults.faultid,usite
