select faultid as [Ticket ID]

,dateoccured as [Date Occurred] 

,(select aareadesc from area where aarea=areaint) as [Customer Name]

,username as [Username]

,(select rtdesc from RequestType where requesttypenew=rtid) as [Request Type]

,category2  as [Category]

,(select uname from uname where assignedtoint=unum) as [Technician]

,(select tstatusdesc from tstatus where tstatus=status) as [Status] 

from faults  where @startdate<dateoccured and dateoccured<@enddate and fdeleted=0
