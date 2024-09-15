select faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Client],
(select sdesc from site where ssitenum=sitenumber) as [Site],
username as [Username],
symptom as [Summary],
(select uother1 from users where uusername=username and usite=sitenumber) as [User Defined 1],
(select uother2 from users where uusername=username and usite=sitenumber) as [User Defined 2],
(select uother3 from users where uusername=username and usite=sitenumber) as [User Defined 3],
(select uother4 from users where uusername=username and usite=sitenumber) as [User Defined 4],
(select uother5 from users where uusername=username and usite=sitenumber) as [User Defined 5],
dateoccured as [Date Occurred],
datecleared as [Date Closed],
(select tstatusdesc from tstatus where tstatus=status) as [Status],
(select uname from uname where unum=assignedtoint) as [Technician] ,
sectio_ as [Section],
(select rtdesc from requesttype where rtid=requesttypenew) as [Request type],
category2 as [Category],
category3 as [Category 2],
category4 as [Category 3],
category5 as [Category 4],
(select pdesc from policy where ppolicy=seriousness and pslaid=slaid) as [Priority],
(select sldesc from slahead where slid=slaid) as [SLA],
slastate as [Resolution State],
slaresponsestate as [Response State],
satisfactionlevel as [Survey Level]
        ,(
                SELECT uname
		FROM uname
		WHERE unum = clearwhoint
                ) AS [Closed By]
from faults  where fdeleted=0

