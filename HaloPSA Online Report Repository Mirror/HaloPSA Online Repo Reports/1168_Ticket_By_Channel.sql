select fvalue as [Channel]
, (select count(faultid) from faults where FRequestSource=fcode and dateoccured>getdate()-30 and fdeleted=0) as [Tickets]
from lookup where fid=22 and fcode<4
