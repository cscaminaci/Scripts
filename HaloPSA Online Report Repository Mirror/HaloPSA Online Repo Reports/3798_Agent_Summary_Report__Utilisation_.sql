select *
,[Target Hours]-[Leave] as [Working Hours Available]
,cast([Target Hours]-[Leave]-[Billable Hours Logged]-[Non-Billable Hours Logged] as decimal(7,2)) as [Missing Hours]
,cast(([Billable Hours Logged]/nullif([Target Hours]-[Leave],0))*100 as decimal(7,2)) as [Billable Logged %]
from (
select  [Agent]
,round(isnull(([Time]),0),2) as [All Hours Logged]
,(
			CASE 
				WHEN walldayssame= 1
				
					THEN (([MON]*cast(wincmonday AS INT) + [TUE]*cast(winctuesday AS INT) + [Wed]*cast(wincwednesday AS INT) + [THU]*cast(wincthursday AS INT) + [FRI]*cast(wincfriday AS INT) + [SAT]*cast(wincsaturday AS INT) + [SUN]*cast(wincsunday AS INT)) * ([WHA] - [uhrsreducer])) - [PHol]

				ELSE  [MON]*cast(wincmonday AS INT) * ([WHA1] - [uhrsreducer]) + [TUE]*cast(winctuesday AS INT) * ([WHA2] - [uhrsreducer]) + [WED]*cast(wincwednesday AS INT) * ([WHA3] - [uhrsreducer]) + [THU]*cast(wincthursday AS INT) * ([WHA4] - [uhrsreducer]) + [FRI]*cast(wincfriday AS INT) * ([WHA5] - [uhrsreducer]) + [SAT]*cast(wincsaturday AS INT) * ([WHA6] - [uhrsreducer]) + [SUN]*cast(wincsunday AS INT) * ([WHA7] - [uhrsreducer])

				END
			) AS [Target Hours]
,[Leave]
,[Admin Time]
,[Training Time]
,[Alerts Monitoring]
,[Billable Hours Logged]
,[Non-Billable Hours Logged]


from
(select
      uname as [Agent]
	  ,usection as [Team]
    , (select round(isnull(sum(timetaken),0),2) from actions where timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate)
    +
    (select isnull(round(cast(sum(antimetaken) as float)/60,2),0) from areanote where anwho=unum and andate>@startdate and andate<@enddate) as [Time]
, (select round(isnull(sum(timetaken),0),2) from actions a join faults f on a.faultid=f.faultid where category2='%Admin%' and timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate) as [Admin Time]
, (select round(isnull(sum(timetaken),0),2) from actions a join faults f on a.faultid=f.faultid where category2='%Training%' and timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate) as [Training Time]
, (select round(isnull(sum(timetaken),0),2) from actions a join faults f on a.faultid=f.faultid where category2='%Alert%' and timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate) as [Alerts Monitoring]
, (select round(isnull(sum(timetaken),0),2) from actions a join faults f on a.faultid=f.faultid where actioncode>-1 and areaint !=12 and timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate) as [Billable Hours Logged]
, (select round(isnull(sum(timetaken),0),2) from actions a join faults f on a.faultid=f.faultid where (actioncode=-1 or areaint =12) and timetaken > 0 and timetaken < 24 and whoagentid=unum and whe_>@startdate and whe_<@enddate) as [Non-Billable Hours Logged]
,DATEDIFF(day,@startdate,@enddate) - DATEDIFF(week,@startdate,@enddate) as [Days]

			,uworkdayid AS [WorkDayID]
			,uhrsreducer AS [uhrsreducer]
			,cast(isnull(datediff(MINUTE, wstart, wend),0)as float)/60 AS [WHA]
			,cast(isnull(datediff(MINUTE, wstart1, wend1),0)as float)/60 AS [WHA1]
			,cast(isnull(datediff(MINUTE, wstart2, wend2),0)as float)/60 AS [WHA2]
			,cast(isnull(datediff(MINUTE, wstart3, wend3),0)as float)/60 AS [WHA3]
			,cast(isnull(datediff(MINUTE, wstart4, wend4),0)as float)/60 AS [WHA4]
			,cast(isnull(datediff(MINUTE, wstart5, wend5),0)as float)/60 AS [WHA5]
			,cast(isnull(datediff(MINUTE, wstart6, wend6),0)as float)/60 AS [WHA6]
			,cast(isnull(datediff(MINUTE, wstart7, wend7),0)as float)/60 AS [WHA7]

			,datediff(day, -6, @enddate)/7-datediff(day, -6, @startdate)/7 AS MON,
 datediff(day, -5, @enddate)/7-datediff(day, -5, @startdate)/7 AS TUE,
 datediff(day, -4, @enddate)/7-datediff(day, -4, @startdate)/7 AS WED,
 datediff(day, -3, @enddate)/7-datediff(day, -3, @startdate)/7 AS THU,
 datediff(day, -2, @enddate)/7-datediff(day, -2, @startdate)/7 AS FRI,
 datediff(day, -1, @enddate)/7-datediff(day, -1, @startdate)/7 AS SAT,
 datediff(day, -0, @enddate)/7-datediff(day, 0, @startdate)/7 AS SUN
 ,(select isnull(sum(Hduration -case when hallday=1 then (DATEDIFF(day,hdate,henddate)+1)*uhrsreducer else 0 end ),0) from HOLIDAYS join uname u on HTechnicianID=u.Unum where HTechnicianID=uname.unum and hdate>@startdate and hdate<@enddate) as [Leave]
 ,wincmonday
 ,winctuesday
 ,wincwednesday
 ,wincthursday
 ,wincfriday
 ,wincsaturday
 ,wincsunday
,walldayssame
,[PHol]

from uname
JOIN workdays ON uworkdayid = wdid
left join (select unum as [AID]
    ,sum(isnull(case 
	    when datepart(weekday,hdate)=1 then cast(wincsunday AS INT)
	    when datepart(weekday,hdate)=2 then cast(wincmonday AS INT)
	    when datepart(weekday,hdate)=3 then cast(winctuesday AS INT)
	    when datepart(weekday,hdate)=4 then cast(wincwednesday AS INT)
	    when datepart(weekday,hdate)=5 then cast(wincthursday AS INT)
	    when datepart(weekday,hdate)=6 then cast(wincfriday AS INT)
	    when datepart(weekday,hdate)=7 then cast(wincsaturday AS INT)
    end,0) * ((cast(isnull(datediff(MINUTE, wstart, wend),0)as float)/60) - uhrsreducer)) as [PHol]
from uname
join WORKDAYS on uworkdayid=wdid
left join HOLIDAYS on hid = wdid
and hdate>=@startdate and hdate<@enddate
group by unum
)[PHols] on [PHols].[AID]=uname.unum

where unum<>1 
and uIsDisabled<>1
)y)d
