select aareadesc as 'Client Name',
                sdesc as 'Site Name',
                faultid as 'Request ID',
                Username as 'User',
                symptom as 'Summary',
                dateoccured as 'Date Logged',                                                                                                                          
                estimate as 'Estimate',
(select top 1 actoutcome from actions where actions.faultid = faults.faultid order by whe_ desc) as 'Last Action Outcome',
(select top 1 who from actions where actions.faultid = faults.faultid order by whe_ desc) as 'Last Action Who',
(select top 1 note from actions where actions.faultid = faults.faultid order by whe_ desc) as 'Last Action Note'
                from faults,site, area
                   where ssitenum=sitenumber
                   and aarea=areaint
                   and status<>9

