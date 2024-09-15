select
	  count(otmfaultid)-count(olmfaultid) as [Open Monthly Variance]
	, count(ctmfaultid)-count(clmfaultid) as [Closed Monthly Variance]
from faults
left join
(select faultid as [otmfaultid] from faults where status != 9 and convert(nvarchar(7), dateoccured, 126) = convert(nvarchar(7), getdate(), 126))otm on otmfaultid = faultid
left join
(select faultid as [olmfaultid] from faults where status != 9 and convert(nvarchar(7), dateoccured, 126) = convert(nvarchar(7), dateadd(mm,-1,getdate()), 126))olm on olmfaultid = faultid
left join
(select faultid as [ctmfaultid] from faults where status = 9 and convert(nvarchar(7), dateoccured, 126) = convert(nvarchar(7), getdate(), 126))ctm on ctmfaultid = faultid
left join
(select faultid as [clmfaultid] from faults where status = 9 and convert(nvarchar(7), dateoccured, 126) = convert(nvarchar(7), dateadd(mm,-1,getdate()), 126))clm on clmfaultid = faultid

