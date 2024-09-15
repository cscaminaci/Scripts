select uname as [Technician]
,(select count(distinct faultid) from actions where uname=who and whe_ >@startdate and whe_<@enddate) as [Tickets worked on]
from uname
