
select *
,round(cast([Tickets Met SLA Yesterday]as float)/cast(nullif([Tickets Resolved Yesterday],0) as float) * 100,2) as [% Met SLA]

from(

select
(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(dateoccured as date) = cast(GETUTCDATE() as date)) as [Tickets Logged Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(dateoccured as date) = cast(GETUTCDATE() as date) and RequestTypeNew=1) as [Incidents Logged Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(dateoccured as date) = cast(GETUTCDATE() as date) and RequestTypeNew=3) as [Service Requests Logged Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(dateoccured as date) = cast(GETUTCDATE() as date) and status not in (8,9)) as [Unresolved from Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(datecleared as date) = cast(GETUTCDATE() as date) and status in (8,9)) as [Tickets Resolved Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(datecleared as date) = cast(GETUTCDATE() as date) and status in (8,9) and Slastate in ('O','X')) as [Tickets Breached SLA Yesterday]
,(select count(faultid) from faults where fdeleted=0 and FMergedIntoFaultid=0 and cast(datecleared as date) = cast(GETUTCDATE() as date) and status in (8,9) and Slastate in ('I')) as [Tickets Met SLA Yesterday]
)d
