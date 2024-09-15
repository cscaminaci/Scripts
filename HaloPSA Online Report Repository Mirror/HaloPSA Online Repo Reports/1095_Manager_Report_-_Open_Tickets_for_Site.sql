select faultid as 'Ticket ID'

,    (select rtdesc from requesttype where rtid=faults.requesttypenew) as 'Ticket Type'
,    (select sdesc from Site where Ssitenum =  sitenumber) as Site
,    faults.faultid as 'Request ID',Username as 'User'
,	Symptom as 'Summary'
,    (select pdesc from Policy where Pslaid=faults.slaid and ppolicy=Faults.seriousness) as 'Priority'
,    Dateoccured as 'Date Created'
,    (select uname from uname where Unum=Faults.assignedtoint)as 'Assigned To'

from faults where dateoccured > @Startdate and dateoccured < @enddate
