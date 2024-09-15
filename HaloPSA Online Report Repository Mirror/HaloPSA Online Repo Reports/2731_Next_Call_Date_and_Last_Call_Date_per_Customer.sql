SELECT distinct
aareadesc as [Customer Name],
convert(nvarchar(10),(select top 1 andate from areanote where aarea=anarea order by andate desc),126) as [Last Call date],
convert(nvarchar(10),ACallDate,126) as [Next Call Date] 
from area
join areanote on aarea=anarea
