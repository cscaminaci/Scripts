
select
	  uname as [Agent]
        , isnull(sum(actionchargeamount),0) as  [Revenue]
        ,isnull(sum(timetaken*isnull(ucostprice,0)),0) as [Cost]
,isnull(sum(actionchargeamount),0) -isnull(sum(timetaken*isnull(ucostprice,0)),0) as [Profit]

from area
left join faults on aarea=areaint and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) 
left join actions on actions.faultid=faults.faultid and whe_>@startdate and whe_<@enddate
left join uname on whoagentid=unum
left join chargerate on crid=actioncode+1  and crarea=0

where actionchargehours>0
group by uname

