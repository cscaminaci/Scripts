select cast(note as nvarchar(150)) as [Email contents],emailto as [To],whe_ as [Date Sent] from actions where emaildirection='O' and whe_>getdate()-1
union
select cast(esemailbody as nvarchar(150)) , cast(esemailto as nvarchar(150)), esdateemailed from emailstore where esdateemailed>getdate()-1
union
select emsubject, emmailaddr, emdate from escmsg where ememailstatus=2
