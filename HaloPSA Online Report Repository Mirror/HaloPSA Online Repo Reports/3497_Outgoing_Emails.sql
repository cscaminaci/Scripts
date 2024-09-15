Select * from (select
convert(varchar,emmailaddr) as [To]
,emdate as [Date]
,convert(nvarchar(max),emsubject) as [Subject]
,convert(nvarchar(max),embodyandfooter) as [Body]
from escmsg where ememailstatus=2
UNION
select
convert(varchar,ESemailto)	
,ESdateemailed
,convert(nvarchar(max),ESemailSubject)
,convert(nvarchar(max),ESemailbody)	
from emailstore
UNION
select 
convert(varchar,EmailToNew)
,dateemailed
,convert(nvarchar(max),emailsubjectnew)
,convert(nvarchar(max),emailbody)
from actions where emaildirection like 'o') OE where [To] is not null

