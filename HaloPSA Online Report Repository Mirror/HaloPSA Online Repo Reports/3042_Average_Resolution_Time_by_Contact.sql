select

uusername as [Contact],
isnull(nullif(round( AVG(elapsedhrs),2),0),0) as [Average Resolution Time (Hours)]

from Faults

join users on userid = uid

where datecleared> GETDATE()-7 
and FexcludefromSLA = 0 
and fdeleted=0

group by uusername

