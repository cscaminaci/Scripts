select who , count(*) as count from actions where whe_>@startdate and whe_<@enddate group by who
