select count(faultid) as Count, 
convert(date,dateoccured,103) as Date,
cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as Time, 
cast(cast(DATEPART(yyyy,dateoccured) as nvarchar)+'-'+cast(DATEPART(MM,dateoccured) as nvarchar)+'-'+cast(DATEPART(dd,dateoccured) as nvarchar)
+' '+cast(DATEPART(hh,dateoccured) as nvarchar)+':00.000' as datetime) as DateTime,
left(weekday_nm,3)+' '+cast(DATEPART(hh,dateoccured) as nvarchar)+':00' as Day
from faults join calendar on convert(date,dateoccured,103)=date_id where fdeleted=0
group by convert(date,dateoccured,103),DATEPART(hh,dateoccured),DATEPART(dd,dateoccured),DATEPART(MM,dateoccured),DATEPART(yyyy,dateoccured),weekday_nm


