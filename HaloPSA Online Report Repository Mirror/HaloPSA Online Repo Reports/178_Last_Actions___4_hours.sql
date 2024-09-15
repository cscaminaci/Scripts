select Faultid as 'Faultid',
username as 'UserName',
(select sdesc from Site where sitenumber = Ssitenum)'Site',
(select aareadesc from Area where Areaint = aarea)'Client',
(select Uname from Uname where unum = assignedtoint)'Tech',
(select TSTATUSdesc from tstatus where TSTATUS = Status)'Status',
symptom as 'Subject',  
dateoccured as 'DateOpened',
(select top 1 whe_ from ACTIONS where ACTIONS.Faultid=Faults.Faultid and who in (select uname from uname) order by 
actionnumber desc)as LastActionTime     
from faults  
where cast((select top 1 whe_ from ACTIONS where ACTIONS.Faultid=Faults.Faultid and who in (select uname from uname) order 
by actionnumber desc) as datetime) < CAST((GETDATE() - '04:00') as datetime)
and fslaonhold <> 1
and status <> 9



