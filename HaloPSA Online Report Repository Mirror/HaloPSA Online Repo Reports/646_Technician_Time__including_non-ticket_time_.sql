select
uname as [Engineer],
(select round(sum(timetaken),2) from actions where uname=who and whe_<@enddate and whe_>@startdate) as [Action 
Time Total],
(select round(sum(hduration),2) from holidays where htype=1 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Holiday],
(select round(sum(hduration),2) from holidays where htype=2 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Meeting],
(select round(sum(hduration),2) from holidays where htype=3 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Sickness],
(select round(sum(hduration),2) from holidays where htype=4 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [IT Issues],                   
(select round(sum(hduration),2) from holidays where htype=5 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Other],
(select round(sum(hduration),2) from holidays where htype=6 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Project Work],
(select round(sum(hduration),2) from holidays where htype=7 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Dentist],
(select round(sum(hduration),2) from holidays where htype=8 and HTechnicianID=unum and hdate>@Startdate and 
hdate<@enddate) as [Doctor]
from uname where uisdisabled=0 

