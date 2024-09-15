select top 5 * from
(
select
	  Category2 as [Category]
	, count(faultid) as [Tickets]
from faults
where convert(date,dateoccured) > convert(date,getdate()-30) and category2 != '' and fdeleted=0
group by category2
)a
order by [Tickets] desc
