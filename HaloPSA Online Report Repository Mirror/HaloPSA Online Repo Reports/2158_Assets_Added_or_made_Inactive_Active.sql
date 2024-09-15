select
aareadesc as [Customer], 
did as [Device ID],
dinvno as [Asset Number],
dcwhen as [Date],
case when DCFieldID=-50 then 'Device Added'
when dcfieldid=-60 and dcnewvalue='True' then 'Made Inactive'
when dcfieldid=-60 and dcnewvalue='False' then 'Made Active'
else '' end as [Type]
 from devicechange 
join device on ddevnum=dcdevnum and dsite=dcdsite
join site on ssitenum=dsite
join area on aarea=sarea
where dcfieldid=-60 or DCFieldID=-50
