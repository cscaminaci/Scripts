SELECT aareadesc as 'Client',        
(SELECT round(avg(isnull(fresponsetime,0)),2) FROM faults WHERE aarea=areaint and status = 9 and fresponsetime <> 0)  as 'Average Response Time (Hours)',        (SELECT round(avg(cast(isnull(datecleared,0) as float)-cast(isnull(dateoccured,0) as float))*24,2) FROM faults WHERE  aarea=areaint and status = 9 and datecleared>5 and datecleared is not null) AS 'Average Closure Time (Hours)' FROM area 

