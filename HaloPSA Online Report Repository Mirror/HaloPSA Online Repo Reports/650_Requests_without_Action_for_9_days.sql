                                    select faults.faultid as 'Request ID',
                (select rtdesc from requesttype where rtid=requesttypenew) as 'Request Type',
                aareadesc as 'Client Name',  
                sdesc as 'Site Name', 
                username as 'User', 
                symptom as 'Summary',  
                (select uname from uname where unum=assignedtoint) as 'Who',
                dateoccured as 'Date Occurred',
                flastactiondate as 'Last Action Date',
                case when fslaonhold=1 then 'On Hold'
                else '' end as 'SLA Status'         
                from faults
                join site on ssitenum=sitenumber
                join area on aarea=areaint
                where status<>9
                and getdate()-9>flastactiondate

