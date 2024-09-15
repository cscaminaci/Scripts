SELECT

sectio_ as 'Section',

(select count(faultid) from faults where Status<>9 and sectio_ = O.sectio_ and FexcludefromSLA=0 )as
'Total Tickets Currently Open',

(select COUNT(faultid) from Faults where sectio_ = O.sectio_ and dateoccured>@startdate and dateoccured<@enddate  
and FexcludefromSLA=0)as 'Tickets Opened This Period',

(select COUNT(faultid) from faults where status=9 and sectio_ = O.sectio_ and datecleared>@startdate and 
datecleared<@enddate  and FexcludefromSLA=0)as 'Tickets Closed This Period',

(select count(faultid) from faults where slastate='O' and sectio_ = O.sectio_ and datecleared>@startdate and 
datecleared<@enddate  and status=9  and FexcludefromSLA=0)as 'SLA Missed',

(select count(faultid) from faults where slastate='I' and sectio_ = O.sectio_ and datecleared>@startdate and 
datecleared<@enddate  and status=9  and FexcludefromSLA=0)as 'SLA Met',

cast((round(cast((select count(faultid) from faults where slastate='O' and sectio_ = O.sectio_ and 
datecleared>@startdate and datecleared<@enddate  and status=9  and FexcludefromSLA=0)as float)
/replace(cast(((select COUNT(faultid) from faults where status=9 and sectio_ = O.sectio_ and datecleared>@startdate 
and datecleared<@enddate   and FexcludefromSLA=0))as float),0,1),4)*100)as nvarchar(50)) + ' %' as 'SLA Missed %',

cast((round(cast((select count(faultid) from faults where slastate='I' and sectio_ = O.sectio_ and 
datecleared>@startdate and datecleared<@enddate  and status=9  and FexcludefromSLA=0)as float)
/replace(cast(((select COUNT(faultid) from faults where status=9 and sectio_ = O.sectio_ and datecleared>@startdate 
and datecleared<@enddate   and FexcludefromSLA=0))as float),0,1),4)*100)as nvarchar(50)) + ' %' as 'SLA Met %'

FROM faults O
where FexcludefromSLA=0     
GROUP BY sectio_


