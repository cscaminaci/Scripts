select fvalue as [Source], (select count(faultid) from faults where frequestsource = fcode and dateoccured>@startdate and dateoccured<@enddate) as [Number of Tickets] from lookup where fid = 22 
