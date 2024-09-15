         select faults.faultid as 'Request ID',
                NULL as 'Action Number',
                aareadesc as 'Client Name',
                sdesc as 'Site Name',
                username as 'User', 
                symptom as 'Summary',
                cast(symptom2 as nvarchar(4000)) as 'Note', 
                reportedby as 'Who',
                round((select sum(isnull(timetaken,0)) from actions where actions.Faultid=faults.Faultid),2) as 'Time Taken', 
                round((select sum(isnull(nonbilltime,0)) from actions where actions.Faultid=faults.Faultid),2) as 'Nonbillable Time',
                dateoccured as 'Date' 
                from faults
                join site on ssitenum=sitenumber
                join area on aarea=areaint
                where status=9
                and datecleared>@startdate
                and datecleared<@enddate
union                                    
select actions.faultid as 'Request ID', 
                actionnumber as 'Action Number',
                aareadesc as 'Client Name',
                sdesc as 'Site Name', 
                username as 'User', 
                symptom as 'Summary',
                cast(note as nvarchar(4000)) as 'Note',
                who as 'Who', 
                timetaken as 'Time Taken', 
                actions.nonbilltime as 'Nonbillable Time',
                whe_ as 'Date Done/Closed' 
                from faults                 
                join actions on faults.faultid=actions.faultid
                join site on ssitenum=sitenumber
                join area on aarea=areaint
                where status=9 
                and datecleared>@startdate
                and datecleared<@enddate
