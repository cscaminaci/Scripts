select 
	  distinct cast(date_id as nvarchar(7)) as [Date]
	, isnull(pvalue,0) as [Projected Sales]
	, isnull(aValue,0) as [Actual Sales]
from calendar
left join
(select convert(nvarchar(7), FOppTargetDate, 126) as [TargetDate],sum((foppconversionprobability*foppvalue)/100) as [pValue] from faults group by convert(nvarchar(7), FOppTargetDate, 126))pipeline on TargetDate=cast(date_id as nvarchar(7))
left join
(select convert(nvarchar(7), FOppConvertedDate, 126) as [ConversionDate],sum(foppvalue) as [aValue] from faults group by convert(nvarchar(7), FOppConvertedDate, 126))actual on ConversionDate=cast(date_id as nvarchar(7))
where date_id>@startdate and date_id<@enddate







