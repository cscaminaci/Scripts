select
    (select aareadesc from area where aarea=areaint) as [Client],
    (select rtdesc from requesttype where rtid=requesttypenew) as [Type],
    count(*) as [No. of Tickets]
    from faults
    where requesttypenew>0 and dateoccured>@startdate and dateoccured<@enddate
    group by requesttypenew,
    areaint




