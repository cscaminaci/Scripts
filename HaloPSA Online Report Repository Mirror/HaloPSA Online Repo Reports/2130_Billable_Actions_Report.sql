
Select *
,sum([Billable Time (Mins)]) over (partition by [Customer] order by [Ticket ID],[When] asc) [Running Total]
from ( select
faults.faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Customer],
who as [Actioned By],
cast(actioncompletiondate as date) as [Action Date],
sectio_ as [Team],
cast(whe_ as date) AS [When],
username as [User],
symptom as [Summary],
    (
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = actioncode + 1
        ) AS 'Charge Rate',
actions.note as [Note]
, replace(cast(convert(decimal(10,2),cast((isnull(timetaken+timetakenadjusted,0)) as int)+
 ((((isnull(timetaken+timetakenAdjusted,0)) -cast((isnull(timetaken+timetakenadjusted,0)) as 
 int))*.60))) as varchar),'.',':') as [Billable Time]
,floor((timetaken+timetakenadjusted)*60) [Billable Time (Mins)]
,1 as 'Order123'
,actioncompletiondate as [Date Filter]
from faults
join actions on faults.faultid=actions.faultid
where fdeleted=0 and fmergedintofaultid=0 

UNION ALL
select 
0 as [Ticket ID],
'___' as [Customer],
'___' as [Actioned By],
cast(isnull(whe_,getdate()) as date) as [Action Date],
sectio_ as [Team],
cast(getdate() as date) as [When],
symptom as [Summary],
'Total'as [User],
    (
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = actioncode + 1
        ) as 'Charge Rate',
'___' as [Note]
, replace(cast(convert(decimal(10,2),cast((isnull(sum(timetaken+timetakenadjusted),0)) as int)+
 ((((isnull(sum(timetaken+timetakenAdjusted),0)) -cast((isnull(sum(timetaken+timetakenadjusted),0)) as 
 int))*.60))) as varchar),'.',':') as [Billable Time]
,floor((sum(timetaken+timetakenadjusted))*60) [Billable Time (Mins)]
,999999 as 'Order123'
,whe_ as [Date Filter]
from faults
join actions on faults.faultid=actions.faultid
where fdeleted=0 and fmergedintofaultid=0 and actoutcome like '%time'
group by actioncode,actions.Whe_,faults.sectio_,actioncompletiondate,symptom)inner1



/*
Previous report

Select *
,sum([Billable Time (Mins)]) over (partition by [Customer] order by [Ticket ID],[When] asc) [Running Total]
from ( select
faults.faultid as [Ticket ID],
(select aareadesc from area where aarea=areaint) as [Customer],
who as [Actioned By],
whe_ as [When],
sectio_ as [Team],
cast(whe_ as date) as [Action Date],
username as [User],
    (
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = actioncode + 1
        ) AS 'Charge Rate'
,symptom as [Summary]
,
actions.note as [Note]
, replace(cast(convert(decimal(10,2),cast((isnull(timetaken+timetakenadjusted,0)) as int)+
 ((((isnull(timetaken+timetakenAdjusted,0)) -cast((isnull(timetaken+timetakenadjusted,0)) as 
 int))*.60))) as varchar),'.',':') as [Billable Time]
,floor((timetaken+timetakenadjusted)*60) [Billable Time (Mins)]
,1 as 'Order123'
from faults
join actions on faults.faultid=actions.faultid
where fdeleted=0 and fmergedintofaultid=0 and timetaken!=0

UNION ALL
select 
0 as [Ticket ID],
'___' as [Customer],
'___' as [Actioned By],
whe_ as [When],
sectio_ as [Team],
cast(getdate() as date) as [Action Date],
'Total'as [User],
    (
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = actioncode + 1
        ) as 'Charge Rate',
'___' as [Note]
,symptom
, replace(cast(convert(decimal(10,2),cast((isnull(sum(timetaken+timetakenadjusted),0)) as int)+
 ((((isnull(sum(timetaken+timetakenAdjusted),0)) -cast((isnull(sum(timetaken+timetakenadjusted),0)) as 
 int))*.60))) as varchar),'.',':') as [Billable Time]
,floor((sum(timetaken+timetakenadjusted))*60) [Billable Time (Mins)]
,999999 as 'Order123'
from faults
join actions on faults.faultid=actions.faultid
where fdeleted=0 and fmergedintofaultid=0 and actoutcome like '%time'
group by actioncode,actions.whe_,sectio_,symptom)inner1
*/
