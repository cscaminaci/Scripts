select c.faultid as [Ticket ID], c.actionnumber as [Action Number], c.who as [Agent Doing], c.[SLA], c.[Priority], 
c.[Agent Assigned], c.[Team], c.date_id as [Date ID], 
case when Workday=1 then 'Yes' else 'No' end as [Workday],
c.whe_ as [Completed], timetaken as [Time Taken], cast(c.[Seconds outside working hours] as decimal)/3600 as [Time Outside Working Hours]

from
(

select *,

case 
when workday=1 and cast(b.[action start time] as time) < cast(b.[work Start Time] as time) and cast(b.[action end time] as time) < cast(b.[work Start Time] as time)
THEN DATEDIFF(SECOND, cast(b.[action start time] as time), cast(b.[action end time] as time))

when workday =1 and cast(b.[action start time] as time) < cast(b.[work Start Time] as time) and cast(b.[action end time] as time) >= cast(b.[work Start Time] as time)
then DATEDIFF(SECOND, cast(b.[action start time] as time), cast(b.[work Start Time] as time))

when workday=1 and cast(b.[action end time] as time) > cast(b.[work end Time] as time) and cast(b.[action Start Time] as time) > cast(b.[work End Time] as time)
THEN DATEDIFF(SECOND, cast(b.[action start time] as time), cast(b.[action end time] as time))

when workday=1 and cast(b.[action end time] as time) > cast(b.[work end Time] as time) and cast(b.[action Start Time] as time) <= cast(b.[work End Time] as time)
THEN DATEDIFF(SECOND, cast(b.[work End Time] as time), cast(b.[action end time] as time))

when Workday=0
then DATEDIFF(SECOND, cast(b.[action start time] as time), cast(b.[action end time] as time))

else 0

end as [Seconds outside working hours]


from
(

select weekday_id, date_id, start_dts, end_dts, whe_,  DATEADD(MINUTE, DATEPART(tz, Whe_ AT TIME ZONE 'GMT Standard Time'), Whe_) as [action end time], 
DATEADD(minute, -60*timetaken, DATEADD(MINUTE, DATEPART(tz, Whe_ AT TIME ZONE 'GMT Standard Time'), Whe_)) as [action Start Time], timetaken,  actions.faultid, who, actionnumber, weekday_nm , sldesc as [SLA], pdesc as [Priority], 
uname as [Agent Assigned], sectio_ as [Team],
case when weekday_id=1 
then (select wincsunday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=2
then (select Wincmonday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=3
then (select Winctuesday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=4
then (select Wincwednesday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=5
then (select Wincthursday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=6 
then (select Wincfriday from WORKDAYS where Wdid=Slwdid) 
 when weekday_id=7
then (select wincsaturday from WORKDAYS where Wdid=Slwdid) 
else -1
end as [Workday],

case when (select walldayssame from WORKDAYS where Wdid=Slwdid)=1 
then (select cast(wstart as time) from WORKDAYS where Wdid=Slwdid)
else case when weekday_id=1 then (select cast(wstart7 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=2 then (select cast(wstart1 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=3 then (select cast(wstart2 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=4 then (select cast(wstart3 as time) from workdays where Wdid=Slwdid)
when weekday_id=5 then (select cast(wstart4 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=6 then (select cast(wstart5 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=7 then (select cast(wstart6 as time) from WORKDAYS where Wdid=Slwdid)
else null
end
end as [work Start Time],

case when (select walldayssame from WORKDAYS where Wdid=Slwdid)=1 
then (select cast(wend as time) from WORKDAYS where Wdid=Slwdid)
else case when weekday_id=1 then (select cast(wend7 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=2 then (select cast(wend1 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=3 then (select cast(wend2 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=4 then (select cast(wend3 as time) from workdays where Wdid=Slwdid)
when weekday_id=5 then (select cast(wend4 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=6 then (select cast(wend5 as time) from WORKDAYS where Wdid=Slwdid)
when weekday_id=7 then (select cast(wend6 as time) from WORKDAYS where Wdid=Slwdid)
else null
end
end as [work End Time]
from CALENDAR
join actions on Whe_>=start_dts and Whe_<=end_dts
join faults on faults.faultid=actions.Faultid
join slahead on slaid=slid
join policy on ppolicy = seriousness and pslaid=slid
join uname on unum=assignedtoint
where timetaken<>0


) b

) c





