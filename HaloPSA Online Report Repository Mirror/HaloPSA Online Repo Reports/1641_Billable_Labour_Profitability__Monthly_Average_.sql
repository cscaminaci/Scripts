select 
 [Customer]
, round([Average Monthly Revenue (£)],2) as [Average Monthly Revenue (£)]
, round([Average Monthly Cost (£)],2) as [Average Monthly Cost (£)]
, round([Average Monthly Revenue (£)]-[Average Monthly Cost (£)],2) as [Average Monthly Profit (£)]
, isnull((([Average Monthly Revenue (£)]-nullif([Average Monthly Cost (£)],0))/nullif([Average Monthly Cost (£)],0))*100,0) as [Profitability (%)]
from
(
select
	  aareadesc as [Customer]
        , isnull(sum(actionchargehours*isnull(crrate,0)),0)/12 as  [Average Monthly Revenue (£)]
        ,isnull(sum(timetaken*isnull(ucostprice,0)),0)/12 as [Average Monthly Cost (£)]
from area
left join faults on aarea=areaint and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) and not fcontractid>0
left join actions on actions.faultid=faults.faultid and whe_>getdate()-365
left join uname on whoagentid=unum
left join chargerate on crid=actioncode+1  and crarea=0
group by aareadesc 
)b
