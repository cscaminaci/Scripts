select aareadesc as 'Client Name',
                sdesc as 'Site Name',
                faultid as 'Request ID',
                Username as 'User',
                symptom as 'Summary',
                dateoccured as 'Date Logged',                                                                                                                          
                estimate as 'Estimate',
                (select uname from uname where Assignedtoint=Unum) as 'Technician'
                from faults,site, area
                   where ssitenum=sitenumber
                   and aarea=areaint
                   and status<>9
