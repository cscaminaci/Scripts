select rtdesc as [Ticket]
,(select fvalue from lookup where fid=21 and fcode=RTRequestType) as [Ticket Type]
,RTDefSection as [Section]
,(select uname from UNAME where unum=RTDefTech) as [Agent]
,(select tstatusdesc from TSTATUS where Tstatus=RTreopenedstatus) as [Status]
,case when RTIncludeInSLA =1 then 'Yes' else 'No' End as [Track SLA]
,case when RTIncludeInSLA=1 then (select Sldesc from slahead where Slid= RTSLAid) else 'N/A' end as [SLA]
,case when RTIncludeInSLA=1 then (select Pdesc from POLICY where Ppolicy= RTDefSeriousness and Pslaid=RTSLAid) else 'N/A' end as [Priority]
,(select fhname from flowheader where fhid=RTWorkFlowID) as [Workflow]
,case when RTAutoStartApproval>0 then (select apdesc from APPROVALPROCESS where apid=RTAutoStartApproval) else 'N/A' end as [Approval]
,(select tstatusdesc from TSTATUS where Tstatus=RTStatusAfterUserUpdate) as [User Updated Status]
,(select tstatusdesc from TSTATUS where Tstatus=RTStatusAfterTechUpdate) as [Agent Updated Status]
,case when RTClosedRequestsWithUpdates=0 then 'Re-Open the Ticket' when RTClosedRequestsWithUpdates=1 then 'Are Ignored' when RTClosedRequestsWithUpdates=2 then 'Repy with an email' when RTClosedRequestsWithUpdates=3 then 'Open a new ticket' when RTClosedRequestsWithUpdates=4 then 'Reply with an email if a set number of hours have passed' when RTClosedRequestsWithUpdates=5 then 'Open a new ticket if a set number of hours have passed' end as [Closed Ticket Emails]
,(select tstatusdesc from TSTATUS where Tstatus=RTreopenedstatus) as [Re-Open Status]

from requesttype 

