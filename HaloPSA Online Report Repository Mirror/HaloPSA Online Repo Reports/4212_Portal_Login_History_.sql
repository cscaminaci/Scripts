select cast(p.pldate as datetime) as [Login Date],
u.uusername as [User Name],
u.uemail as [Email],
p.plmethod as [Login Method],
p.plip as [IP Address],
p.plsuccess as [Success]
from portallog as p
inner join users u on p.plfkid = u.uid and p.pltype=0
