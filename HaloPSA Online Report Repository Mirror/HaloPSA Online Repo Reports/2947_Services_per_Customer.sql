select 
aareadesc as [Customer],
stdesc as [Service]
from SERVICEUSER
join servsite on stid=SUSTid
join area on aarea=suarea
where suarea>0

