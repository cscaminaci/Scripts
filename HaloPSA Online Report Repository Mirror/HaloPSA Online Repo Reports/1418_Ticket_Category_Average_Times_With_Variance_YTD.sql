Select *
	,[Time Taken]-[Average Time] as [Variance]

from(

select faultid as [Ticket ID]
,(select uname from uname where unum=Assignedtoint) as [Agent]
,category2 as [Category]
,(select round(sum(timetaken),2) from actions a where a.faultid=faults.Faultid) as [Time Taken]

,(select d.AVGTime from (select category2 as [CatAVG]
							,round(sum(timetaken)/count(f.Faultid),2) as [AVGTime]
							from FAULTS f
							join actions a on a.faultid=f.Faultid
							where fdeleted=0 
							and fmergedintofaultid =0
							and category2 <> ''
							and year(dateoccured)=YEAR(GETUTCDATE())
							group by category2)d where category2=d.CatAVG) as [Average Time]

from faults
where fdeleted=0 
and fmergedintofaultid =0
and dateoccured>@startdate
and dateoccured<@enddate
and category2 <> '')a



