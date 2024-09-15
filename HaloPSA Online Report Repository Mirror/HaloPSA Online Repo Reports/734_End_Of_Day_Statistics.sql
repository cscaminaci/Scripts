select
SDSectionname as [Section]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and convert(date, dateoccured)=convert(date, getdate())) as [New Logged]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and convert(date, dateoccured)=convert(date, (getdate()-1)) and status not in (8, 9)) as [CF Yesterday]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and convert(date, datecleared)=convert(date, getdate())) as [Closed Today]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and status not in (8, 9)) as [Currently Open]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and status not in (8, 9) and dateoccured<DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) 
and isnull(datecleared,0)<100) as [Open at close of yesterday]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and status not in (8, 9) and getdate()-dateoccured>3 and getdate()-dateoccured<7) as [3-6 Days Old]
, (select count(*) from faults where sectio_=sdsectionname and fdeleted=0 and status not in (8, 9) and getdate()-dateoccured>7) as [7+ Days Old]
from SectionDetail 

