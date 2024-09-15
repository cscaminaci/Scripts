--DYNAMIC
DECLARE @columns VARCHAR(max);
DECLARE @sql VARCHAR(max);
SET @columns = N''; 

SELECT @columns += (    SELECT stuff((       SELECT ',' + '[' + [state2] + ']'       
FROM (
select top 100 cast ([state] as nvarchar(200)) as [state2] from (select fvalue as 'state' from lookup where fid=78      ) a order by 'state2') n      
FOR XML PATH('')       ), 1, 1, '')    );    

SET @SQL = '
select * from (select 
uname as [Agent],
fvalue as [status]
from agentcheckin
join uname on unum=aciunum
join lookup on fid=78 and fcode=acistatus) src
pivot (count([status]) for [status] in ('    + @columns + ')) pvt'

EXEC (@sql);  

