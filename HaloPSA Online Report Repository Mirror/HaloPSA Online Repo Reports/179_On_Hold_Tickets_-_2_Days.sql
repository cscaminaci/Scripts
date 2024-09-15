select Faultid as 'Faultid',
username as 'Username',
(select sdesc from Site where sitenumber = Ssitenum)'Site',
(select aareadesc from Area where Areaint = aarea)'Client',
(select Uname from Uname where unum = assignedtoint)'Tech',
(select TSTATUSdesc from tstatus where TSTATUS = Status)'Status',
symptom as 'Subject',     
dateoccured as 'Date Opened',
(select top 1 whe_ from ACTIONS where ACTIONS.Faultid=Faults.Faultid order by actionnumber desc)as LastActionTime   
from faults
where cast((select top 1 whe_ from ACTIONS where ACTIONS.Faultid=Faults.Faultid order by actionnumber desc) as datetime) < 
DateAdd(day, -2, getdate())
and fslaonhold = 1
and Status <> 9


