select 
	[Engineer]
	, [Monday]
	, [Tuesday]
	, [Wednesday]
	, [Thursday]
	, [Friday]
	, round(isnull(([Monday]+[Tuesday]+[Wednesday]+[Thursday]+[Friday])/nullif([Days],0),0),2) as [Daily Average]
,round(isnull(([Monday]+[Tuesday]+[Wednesday]+[Thursday]+[Friday]),0),2) as [Total Hours]
from
(select
      uname as [Engineer]
    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and who=uname and convert(date,dateadd(hour,10,whe_)) in
    (select date_id from calendar where weekday_id=2 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        ) + (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and convert(date,dateadd(hour,10,andate)) in
    (select date_id from calendar where weekday_id=2 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )    as [Monday]

    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and who=uname and convert(date,dateadd(hour,10,whe_)) in
    (select date_id from calendar where weekday_id=3 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        ) + (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and convert(date,dateadd(hour,10,andate)) in
    (select date_id from calendar where weekday_id=3 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )    as [Tuesday]

    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and who=uname and convert(date,dateadd(hour,10,whe_)) in
    (select date_id from calendar where weekday_id=4 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        ) + (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and convert(date,dateadd(hour,10,andate)) in
    (select date_id from calendar where weekday_id=4 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )    as [Wednesday]

    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and who=uname and convert(date,dateadd(hour,10,whe_)) in
    (select date_id from calendar where weekday_id=5 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )  + (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and convert(date,dateadd(hour,10,andate)) in
    (select date_id from calendar where weekday_id=5 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )   as [Thursday]

    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and who=uname and convert(date,dateadd(hour,10,whe_)) in
    (select date_id from calendar where weekday_id=6 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        ) + (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and convert(date,dateadd(hour,10,andate)) in
    (select date_id from calendar where weekday_id=6 and date_id<convert(date,dateadd(hour,10,@enddate)) and date_id>=convert(date,dateadd(hour,10,@startdate)))
        )    as [Friday]
,DATEDIFF(day,@startdate,@enddate) - DATEDIFF(week,@startdate,@enddate) as [Days]
    
from uname
where unum<>1 and uIsDisabled<>1
)y
