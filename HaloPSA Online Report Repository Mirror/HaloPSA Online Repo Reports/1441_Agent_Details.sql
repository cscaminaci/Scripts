select uname as [Agent Name]
,usmtp as [Email Address]
,UJobTitle as [Job Title]
,(select name + CHAR(13) from NHD_Roles where id in (select RoleId from NHD_UserRoles where UserId in (select id from NHD_User where NormalizedUserName=uname))
        ORDER BY id 
        FOR XML PATH (''), TYPE
    ).value('.', 'varchar(max)')  as [Agent Roles]
,usection as [Default Section]
,(select wdesc from workdays where wdid=UWorkDayID) as [Working Days]
,uhrsreducer as [Lunch Break]



from UNAME
where Unum<>1
and Uisdisabled=0
