 select [Customer] ,
 first_day_of_month as [Month],
 sum([Summed]) as [Total]
 from (
select
aareadesc as [Customer], 
did as [Device ID],
dinvno as [Asset Number],
dcwhen as [Date],
case when DCFieldID=-50 then 'Device Added'
when dcfieldid=-60 and dcnewvalue='True' then 'Made Inactive'
when dcfieldid=-60 and dcnewvalue='False' then 'Made Active'
else '' end as [Type],
case when DCFieldID=-50 then 1
when dcfieldid=-60 and dcnewvalue='True' then -1
when dcfieldid=-60 and dcnewvalue='False' then 1
else '' end as [Summed]
 from devicechange 
join device on ddevnum=dcdevnum and dsite=dcdsite
join site on ssitenum=dsite
join area on aarea=sarea
where dcfieldid=-60 or DCFieldID=-50 )b
join calendar on date_day=1 and [Date]>start_dts and [Date]<last_day_of_month
group by [Customer],first_day_of_month
