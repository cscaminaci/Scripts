select faultid as [Project ID]
     , case when fxrefto is null then faultid
            when fxrefto = 0 then faultid
			else fxrefto
			end as [Parent ID]
	 , case when fxrefto is null then 'Parent'
            when fxrefto = 0 then 'Parent'
            when fxrefto in (select parent.faultid from faults parent join requesttype on rtid=parent.requesttypenew where faults.fxrefto=parent.faultid and rtisopportunity<>0) then 'Parent'
			else 'Child of Project '+cast(fxrefto as nvarchar(50)) 
			end as [Type]
     ,Symptom as [Summary]
     ,(select tstatusdesc from tstatus where tstatus=Status) as [Status]
     ,FTargetDate as [Target Date] 
     ,(Select uname from Uname where Unum=Assignedtoint)as [Agent]
	 , case when fxrefto is null then FProjectTimeActual
            when fxrefto = 0 then FProjectTimeActual
			else (select sum(timetaken) from actions where actions.faultid=faults.faultid) 
			end as [Actual Project Time]
     ,Username as [Username]
from faults
where requesttypenew in (select rtid from requesttype where RTIsProject=1) and fdeleted=0
