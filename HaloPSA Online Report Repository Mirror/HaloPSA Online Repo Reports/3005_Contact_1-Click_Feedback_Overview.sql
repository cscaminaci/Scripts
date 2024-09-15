select
	 distinct uusername as [Contact]
	, (select count(*) from faults where userid=uid and requesttype in (1,2,3) and dateoccured > @startdate and dateoccured < @enddate and fdeleted = 0 and fmergedintofaultid = 0) as [Tickets Raised]
	, (select count(*) from faults where userid=uid and requesttype in (1,2,3) and datecleared > @startdate and datecleared < @enddate and fdeleted = 0 and fmergedintofaultid = 0) as [Tickets Closed]
	, (select round(avg(elapsedhrs),2) from faults where userid=uid and requesttype in (1,2,3) and datecleared > @startdate and datecleared < @enddate and fdeleted = 0 and fmergedintofaultid = 0) as [Average Resolution Time (hours)]
	, (select count(faultid) from faults where userid=uid and requesttype in (1,2,3) and datecleared > @startdate and datecleared < @enddate and satisfactionlevel in (1,2) and fdeleted = 0 and fmergedintofaultid = 0) as [Positive Feedback]
        , (select count(faultid) from faults where userid=uid and requesttype in (1,2,3) and datecleared > @startdate and datecleared < @enddate and satisfactionlevel in (3,4) and fdeleted = 0 and fmergedintofaultid = 0) as [Negative Feedback]
        , (select isnull(round(sum(timetaken),2),0) from actions join faults on actions.faultid=faults.faultid where userid=uid and requesttype in (1,2,3) and whe_ > @startdate and whe_ < @enddate and fdeleted = 0 and fmergedintofaultid = 0) as [Time Logged (hours)]
from users
Join faults on userid=uid
Where satisfactionlevel is not null
