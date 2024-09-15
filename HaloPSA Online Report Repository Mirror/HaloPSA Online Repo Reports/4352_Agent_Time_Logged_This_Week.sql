select 
	  [Agent]
	, [Monday]
	, [Tuesday]
	, [Wednesday]
	, [Thursday]
	, [Friday]
	, round(isnull(([Monday]+[Tuesday]+[Wednesday]+[Thursday]+[Friday])/nullif(Days,0),0),2) as [Daily Average]
from
(select *, 
	(
        select count(*)
        from (values (z.Monday), (z.Tuesday), (z.Wednesday), (z.Thursday), (z.Friday)) as v(col)
        where v.col != 0
    ) as [Days]
from
(select
      uname as [Agent]
    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )  as [Monday]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )  as [Tuesday]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )  as [Wednesday]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )  as [Thursday]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )  as [Friday]
    
from uname
where unum<>1 and uIsDisabled<>1
)z
)y

