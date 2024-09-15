
select uname as [Technician]
,(select count(Faultid) from actions where emailto<>'' and who =uname and dateemailed>@startdate and dateemailed<@enddate) as [Emails]
,(select count(clid) from CALLLOG where CLunum=unum and cldate>@startdate and CLdate<@enddate) as [Calls]
from uname
where Uisdisabled=0 and Unum <> 1
