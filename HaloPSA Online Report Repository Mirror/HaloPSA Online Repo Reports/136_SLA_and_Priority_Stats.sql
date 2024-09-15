   SELECT 
(select  sldesc from slahead where slid = O.slaid) as  'SLA',
(select top 1 pdesc from policy where ppolicy = O.seriousness and pslaid=O.slaid) as 'Priority',
(select count(faultid) from faults where Status<>9 and seriousness = O.seriousness and FexcludefromSLA=0 )as 'Total Tickets 
Currently Open',
(select COUNT(faultid) from Faults where seriousness = O.seriousness and slaid = O.slaid and dateoccured>@startdate and dateoccured<@enddate  
and FexcludefromSLA=0)as 'Tickets Opened This Period',
(select COUNT(faultid) from faults where status=9 and seriousness = O.seriousness and slaid = O.slaid and datecleared>@startdate and 
datecleared<@enddate  and FexcludefromSLA=0)as 'Tickets Closed This Period',

(select count(faultid) from faults where slastate='O' and seriousness = O.seriousness and slaid = O.slaid and datecleared>@startdate and 
datecleared<@enddate  and status=9  and FexcludefromSLA=0)as 'SLA Fix Missed',
(select count(faultid) from faults where slastate='I' and seriousness = O.seriousness and slaid = O.slaid and datecleared>@startdate and 
datecleared<@enddate  and status=9  and FexcludefromSLA=0)as 'SLA Fix Met',
cast((round(cast((select count(faultid) from faults where slastate='O' and seriousness = O.seriousness and slaid = O.slaid and 
datecleared>@startdate and datecleared<@enddate  and status=9  and FexcludefromSLA=0)as float)
/replace(cast(((select COUNT(faultid) from faults where status=9 and seriousness = O.seriousness and slaid = O.slaid and datecleared>@startdate 
and datecleared<@enddate   and FexcludefromSLA=0))as float),0,1),4)*100)as nvarchar(50)) + ' %' as 'SLA Fix Missed %',

(select count(faultid) from faults where slaresponsestate='O' and seriousness = O.seriousness and slaid = O.slaid and dateoccured>@startdate 
and dateoccured<@enddate and FexcludefromSLA=0)as 'SLA Response Missed',
(select count(faultid) from faults where slaresponsestate='I' and seriousness = O.seriousness and slaid = O.slaid and dateoccured>@startdate 
and dateoccured<@enddate and FexcludefromSLA=0)as 'SLA Response Met',                                     
(select count(faultid) from faults where slaresponsestate is null and seriousness = O.seriousness and slaid = O.slaid and 
dateoccured>@startdate and dateoccured<@enddate and FexcludefromSLA=0)as 'SLA Response Awaiting',                           
         

cast((round(cast((select count(faultid) from faults where slaresponsestate='O' and dateoccured>@startdate and 
dateoccured<@enddate and seriousness = O.seriousness and slaid = O.slaid  and FexcludefromSLA=0)as float)
/replace(cast(((select COUNT(faultid) from faults where seriousness = O.seriousness and slaid = O.slaid and dateoccured>@startdate and 
dateoccured<@enddate    and FexcludefromSLA=0))as float),0,1),4)*100)as nvarchar(50)) + ' %' as 'SLA Response Missed %'
FROM faults O
where FexcludefromSLA=0
GROUP BY seriousness,slaid   

