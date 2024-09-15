select
      uname as [Engineer]
    , usection as [Section]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )    as [Time (Monday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)<=
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))    
    and (datecleared='' or convert(date,datecleared)>
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    ) ) as [Open (Monday)]
    , (select count(faultid) from faults where unum=clearwhoint and status = 9 and convert(date,datecleared)=
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [Closed (Monday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)=
    (select date_id from calendar where weekday_id=2 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [New (Monday)]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )    as [Time (Tuesday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)<=
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))    
    and (datecleared='' or convert(date,datecleared)>
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    ) ) as [Open (Tuesday)]
    , (select count(faultid) from faults where unum=clearwhoint and status = 9 and convert(date,datecleared)=
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [Closed (Tuesday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)=
    (select date_id from calendar where weekday_id=3 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [New (Tuesday)]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )    as [Time (Wednesday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)<=
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))    
    and (datecleared='' or convert(date,datecleared)>
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    ) ) as [Open (Wednesday)]
    , (select count(faultid) from faults where unum=clearwhoint and status = 9 and convert(date,datecleared)=
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [Closed (Wednesday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)=
    (select date_id from calendar where weekday_id=4 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [New (Wednesday)]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )    as [Time (Thursday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)<=
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))    
    and (datecleared='' or convert(date,datecleared)>
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    ) ) as [Open (Thursday)]
    , (select count(faultid) from faults where unum=clearwhoint and status = 9 and convert(date,datecleared)=
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [Closed (Thursday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)=
    (select date_id from calendar where weekday_id=5 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [New (Thursday)]

    , (select round(isnull(sum(timetaken),0),2) from actions where who=uname and convert(date,whe_) =
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
        )    as [Time (Friday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)<=
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))    
    and (datecleared='' or convert(date,datecleared)>
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    ) ) as [Open (Friday)]
    , (select count(faultid) from faults where unum=clearwhoint and status = 9 and convert(date,datecleared)=
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [Closed (Friday)]
    , (select count(faultid) from faults where unum=assignedtoint and convert(date,dateoccured)=
    (select date_id from calendar where weekday_id=6 and date_id<=convert(date,getdate()) and date_id>convert(date,getdate()-6) and weekday_id <= (select weekday_id from calendar where 
date_id=convert(date,getdate())))
    )    as [New (Friday)]
    
from uname
where unum<>1



