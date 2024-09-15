select [M-T]+[FRIM]+[FRID]+[SAT]+[SUN] as [Tickets resolved within 8 hours]
	,cast(round((cast([M-T]+[FRIM]+[FRID]+[SAT]+[SUN] as real))/nullif(cast([ALL] as real),0)*100,2) as nvarchar) + '%' as [% Resolved within 8 hours]
	,(select count(*) from faults where DATEDIFF (Minute, dateoccured, datecleared) <30  and DATEDIFF (minute, dateoccured, datecleared) >0 and dateoccured > @startdate and dateoccured < @enddate and RequestTypeNew<>12) as [Tickets resolved within 30 minutes]
	,cast(round((select cast(count(*) as real) from faults where DATEDIFF (Minute, dateoccured, datecleared) <30  and DATEDIFF (minute, dateoccured, datecleared) >0 and dateoccured > @startdate and dateoccured < @enddate and RequestTypeNew<>12)/nullif(cast([ALL] as real),0)*100,2) as nvarchar) + '%' as [% Resolved within 30 minutes]
FROM(

select

(select count(*) from faults
WHERE dateoccured >@startdate 
and dateoccured <@enddate 
and RequestTypeNew<>12) as [ALL]

,(Select count(*)
From(
SELECT faultid
	,dateoccured
	,Datecleared
	,(select weekday_id from calendar where convert(nvarchar(10),dateoccured,120) = date_id) as [Weekday ID]
FROM faults 
WHERE dateoccured >@startdate 
and dateoccured <@enddate
and status = 9
and RequestTypeNew<>12)d
where [Weekday ID] in (2,3,4,5)
and DATEDIFF (minute, dateoccured, datecleared) <1440
and DATEDIFF (minute, dateoccured, datecleared) >0) as [M-T]

,(Select count(*)
From(
SELECT faultid
	,dateoccured
	,Datecleared
	,(select weekday_id from calendar where convert(nvarchar(10),dateoccured,120) = date_id) as [Weekday ID]
FROM faults 
WHERE dateoccured >@startdate 
and dateoccured <@enddate
and status = 9
and RequestTypeNew<>12)d
where [Weekday ID] in (6)
and CONVERT(nvarchar(5),dateoccured,106) <= '09:00'
and DATEDIFF (minute, dateoccured, datecleared) <1440
and DATEDIFF (minute, dateoccured, datecleared) >0) as [FRIM]

,(Select count(*)
From(
SELECT faultid
	,dateoccured
	,Datecleared
	,(select weekday_id from calendar where convert(nvarchar(10),dateoccured,120) = date_id) as [Weekday ID]
FROM faults 
WHERE dateoccured >@startdate 
and dateoccured <@enddate
and status = 9
and RequestTypeNew<>12)d
where [Weekday ID] in (6)
and CONVERT(nvarchar(5),dateoccured,106) > '09:00'
and DATEDIFF (minute, dateoccured, datecleared) <4320
and DATEDIFF (minute, dateoccured, datecleared) >0) as [FRID]

,(Select count(*)
From(
SELECT faultid
	,dateoccured
	,Datecleared
	,(select weekday_id from calendar where convert(nvarchar(10),dateoccured,120) = date_id) as [Weekday ID]
FROM faults 
WHERE dateoccured >@startdate 
and dateoccured <@enddate
and status = 9
and RequestTypeNew<>12)d
where [Weekday ID] in (7)
and DATEDIFF (minute, dateoccured, datecleared) <4320
and DATEDIFF (minute, dateoccured, datecleared) >0) as [SAT]

,(Select count(*)
From(
SELECT faultid
	,dateoccured
	,Datecleared
	,(select weekday_id from calendar where convert(nvarchar(10),dateoccured,120) = date_id) as [Weekday ID]
FROM faults 
WHERE dateoccured >@startdate 
and dateoccured <@enddate
and status = 9
and RequestTypeNew<>12)d
where [Weekday ID] in (7)
and DATEDIFF (minute, dateoccured, datecleared) <2880
and DATEDIFF (minute, dateoccured, datecleared) >0) as [SUN]
)d
