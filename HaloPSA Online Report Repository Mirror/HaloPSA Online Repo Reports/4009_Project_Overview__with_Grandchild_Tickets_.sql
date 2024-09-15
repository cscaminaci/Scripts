select f.faultid as [Ticket ID]
     , case when fxrefto is null then faultid
            when fxrefto = 0 then faultid
            when fxrefto in (select parent.faultid from faults parent join requesttype on rtid=parent.requesttypenew where f.fxrefto=parent.faultid and rtisopportunity<>0) then faultid
            when fxrefto in (select parent.faultid from faults parent where f.fxrefto=parent.faultid and parent.fxrefto in (select grandparent.faultid from faults grandparent where grandparent.faultid=parent.fxrefto and grandparent.requesttypenew=5)) then (select parent.fxrefto from faults parent where f.fxrefto=parent.faultid)
			else fxrefto
			end as [Parent ID]
	 , case when fxrefto is null then 'Parent'
            when fxrefto = 0 then 'Parent'
            when fxrefto in (select parent.faultid from faults parent join requesttype on rtid=parent.requesttypenew where f.fxrefto=parent.faultid and rtisopportunity<>0) then 'Parent'
            when fxrefto in (select parent.faultid from faults parent where f.fxrefto=parent.faultid and parent.requesttypenew=5) then 'Child of Project '+cast(fxrefto as nvarchar(50))
            when fxrefto in (select parent.faultid from faults parent where f.fxrefto=parent.faultid and parent.fxrefto in (select grandparent.faultid from faults grandparent where grandparent.faultid=parent.fxrefto and grandparent.requesttypenew=5)) then 'Grandchild of Project '+cast((select parent.fxrefto from faults parent where f.fxrefto=parent.faultid) as nvarchar(50))
            else 'Unknown'

			end as [Relationship]
     ,Symptom as [Summary]
     ,(select tstatusdesc from tstatus where tstatus=Status) as [Status]
     ,FTargetDate as [Target Date] 
     ,(Select uname from Uname where Unum=Assignedtoint)as [Agent]
	 ,(select sum(timetaken) from actions where actions.faultid=f.faultid) as [Time on Ticket]
     ,Username as [Username]
     ,(select rtdesc from requesttype where rtid=requesttypenew) as [Ticket Type]
from faults f
where requesttypenew in (select rtid from requesttype where RTIsProject=1)
