select Wdesc as [Working Days]
, case when Walldayssame=1 and Wincmonday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincmonday=1 then convert(nvarchar(5),Wstart1,114) +'-'+ convert(nvarchar(5),Wend1,114) 
else 'Not a Working Day' end as [Monday]
, case when Walldayssame=1 and Winctuesday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Winctuesday=1 then convert(nvarchar(5),wstart2,114) +'-'+ convert(nvarchar(5),Wend2,114) 
else 'Not a Working Day' end as [Tuesday]
, case when Walldayssame=1 and Wincwednesday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincwednesday=1 then convert(nvarchar(5),Wstart3,114) +'-'+ convert(nvarchar(5),Wend3,114) 
else 'Not a Working Day' end as [Wednesday]
, case when Walldayssame=1 and Wincthursday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincthursday=1 then convert(nvarchar(5),Wstart4,114) +'-'+ convert(nvarchar(5),Wend4,114) 
else 'Not a Working Day' end as [Thursday]
, case when Walldayssame=1 and Wincfriday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincfriday=1 then convert(nvarchar(5),Wstart5,114) +'-'+ convert(nvarchar(5),Wend5,114) 
else 'Not a Working Day' end as [Friday]
, case when Walldayssame=1 and Wincsaturday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincsaturday=1 then convert(nvarchar(5),Wstart6,114) +'-'+ convert(nvarchar(5),Wend6,114) 
else 'Not a Working Day' end as [Saturday]
, case when Walldayssame=1 and Wincsunday=1 then convert(nvarchar(5),Wstart,114) +'-'+ convert(nvarchar(5),Wend,114)
when Walldayssame<>1 and Wincsunday=1 then convert(nvarchar(5),wstart7,114) +'-'+ convert(nvarchar(5),Wend7,114) 
else 'Not a Working Day'end as [Sunday]
from WORKDAYS
