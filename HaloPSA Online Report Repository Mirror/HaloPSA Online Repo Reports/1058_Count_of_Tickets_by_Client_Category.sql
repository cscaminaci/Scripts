
select 
	(select aareadesc from area where aarea = areaint) as [Client],
	category2 as [Category],
	count(faultid) as [Count of Tickets]
from faults
where datecleared > @startdate and datecleared < @enddate and status = 9 and fdeleted=0
group by areaint,category2

