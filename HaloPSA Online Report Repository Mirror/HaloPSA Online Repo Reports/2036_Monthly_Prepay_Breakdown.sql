select aareadesc as [Customer]
,date_id as [Start of Month]
,month_nm+' '+cast(date_year as nvarchar(4)) as [Month/Year]
,(select sum(pphours) from Prepayhistory where aarea=ppareaint and ppdate>start_dts and ppdate<last_day_of_month) as [Bought],
(select sum(actionprepayhours) from actions join faults on faults.faultid=actions.faultid and aarea=areaint and whe_>start_dts and whe_<last_day_of_month) as [Used],
(select sum(pphours) from Prepayhistory where aarea=ppareaint and ppdate<last_day_of_month)-
(select sum(actionprepayhours) from actions join faults on faults.faultid=actions.faultid and aarea=areaint and whe_<last_day_of_month) as [Running Total]
 from calendar 
join area on 1=1
where date_day=1
and date_id>getdate()-365
