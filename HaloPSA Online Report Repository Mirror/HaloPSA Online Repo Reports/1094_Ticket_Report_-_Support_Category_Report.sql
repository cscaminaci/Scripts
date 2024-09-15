Select faultid as 'Ticket ID'

,    aareadesc as [Client]



,    Username as 'User'



,    category2 as 'Support Section'



,    dateoccured as 'Date Logged'

, sectio_ as 'Team'
, rtdesc as 'Ticket Type'
, tstatusdesc as 'Status'

,    (Select top 1 whe_ from actions where actions.faultid = faults.faultid order by whe_ desc) as 'Last Action Date'



from faults 
join requesttype on rtid=requesttypenew
join tstatus on tstatus=status
join area on aarea=areaint
 where category2 = 'Support' and dateoccured > @Startdate and dateoccured < @enddate

