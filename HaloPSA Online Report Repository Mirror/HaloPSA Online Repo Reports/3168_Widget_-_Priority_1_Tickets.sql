select count(faultid) as [test], 'Priority 1 Ticket(s)' as [b] from faults where dateoccured between @startdate and @enddate and areaint=$clientid and seriousness=1 and fdeleted=0
