select (select count(*) from faults where dateoccured > @startdate and dateoccured <@enddate) as [Logged tickets]
	,(select count(*) from faults where status=9 and datecleared > @startdate and datecleared <@enddate) as [Closed tickets]
