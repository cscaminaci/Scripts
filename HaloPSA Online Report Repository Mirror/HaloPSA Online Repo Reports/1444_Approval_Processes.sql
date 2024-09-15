select apdesc as [Approval Process]
,ASsequence as [Sequence]
,case when ASType = 1 then 'A Fixed Agent'
when ASType = 3 then 'A Fixed CAB'
when ASType = 7 then 'A Fixed User'
when ASType = 12 then 'A Fixed Email Address'
when ASType = 2 then 'The Defined Change Approver At the Site'
when ASType = 6 then 'The User'
when ASType = 10 then 'The Users Manager (in AD)'
when ASType = 15 then 'The Users 2nd Level Manager (in AD)'
when ASType = 5 then 'The Head of the Users Default Department'
when ASType = 8 then 'Ad-hoc Approver'
when ASType = 30 then 'Choose Agent when starting process'
when ASType = 9 then 'Choose CAB when starting process'
when ASType = 13 then 'Choose from a list of approvers when starting the process'
when ASType = 40 then 'Choose from a list of approvers users at the client'
when ASType = 41 then 'Choose from a list of approvers users at all client'
when ASType = 4 then 'Determined by Global Approval Process Rules'
when ASType = 42 then 'Determined by Local Approval Process Rules'
End as [Approval Type]
,case when ASType=1 then (select uname from uname where unum=ASUnumCAB)
when ASType=3 then (select bhdesc from CABHEADER where BHid=ASUnumCAB)
when ASType=7 then ASSelectedUsername
when ASType=12 then ASEmailAddress
else 'N/A'
END as [Approver(s)]

from APPROVALPROCESS
join APPROVALPROCESSSTEP on APid=ASProcessID

