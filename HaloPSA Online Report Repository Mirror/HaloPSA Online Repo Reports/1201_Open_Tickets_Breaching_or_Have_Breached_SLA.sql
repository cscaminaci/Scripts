select *
from(


select aareadesc as [Client]
,sdesc [site]
,username [User]
,dateoccured [Date Created]
,symptom [Summary]
,rtdesc [Ticket Type]
,faultid [Ticket ID]


from faults
join requesttype on requesttypenew=rtid
join site on ssitenum=sitenumber
join area on aarea=areaint
where fdeleted = 0
and SLAresponseState in ('O','X')
and status != 9 
and fexcludefromsla=0


UNION

select aareadesc as [Client]
,sdesc [Site]
,username [User]
,dateoccured [Date Created]
,symptom [Summary]
,rtdesc [Ticket Type]
,faultid [Ticket ID]


from faults
join requesttype on requesttypenew=rtid
join site on ssitenum=sitenumber
join area on aarea=areaint
where dbo.GetSLATimeLeft(dateadd(minute,datediff(minute,getutcdate(),getdate()),frespondbydate),slaid)<2 and status != 9 
and slaresponsestate is null and (reportedby not like '%spreadsheet%' or reportedby is null)
and fexcludefromsla=0 and (fresponsedate is null or fresponsedate<5)
and fdeleted = 0

)d

group by [Ticket ID],[Client],[Site],[User],[Date Created],[Ticket Type],[Ticket ID],[Summary]
