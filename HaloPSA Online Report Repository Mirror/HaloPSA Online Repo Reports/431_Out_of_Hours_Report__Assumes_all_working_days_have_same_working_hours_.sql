select
faultid as [Ticket ID],
symptom as [Subject],
symptom2 as [Details],
(select tstatusdesc from tstatus where tstatus=status)Status,
dateoccured as [Date Occurred],
(Select sdesc from site where ssitenum=sitenumber) as Site,
(select pdesc from policy where ppolicy=seriousness and slaid=pslaid)Priority,
Category2 as [Support Category]
from faults join calendar on floor(cast(dateoccured as float))=floor(cast(start_dts as float))
where cast(dateoccured as time)<cast((select wstart from workdays where wdid=(select slwdid 
from 
slahead where slaid=slid)) as time)
or cast(dateoccured as time)>cast((select wend from workdays where wdid=(select slwdid from 
slahead 
where slaid=slid)) as time)
or ((select wincMonday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and            
weekday_nm='Monday')
or ((select wincTuesday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and            
weekday_nm='Tuesday')
or ((select wincWednesday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and            
weekday_nm='Wednesday')
or ((select wincThursday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and            
weekday_nm='Thursday')
or ((select wincfriday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and            
weekday_nm='Friday')
or ((select wincsaturday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and 
weekday_nm='Saturday')
or ((select wincsunday from workdays where wdid=(select slwdid from slahead where slaid=slid))=0 and 
weekday_nm='Sunday')
and dateoccured > @startdate
and dateoccured < @enddate
