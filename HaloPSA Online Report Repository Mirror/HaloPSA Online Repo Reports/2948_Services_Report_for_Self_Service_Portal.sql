select 
stdesc as [Service]
from SERVICEUSER
join servsite on stid=SUSTid
join area on aarea=suarea
where suarea=$clientid

