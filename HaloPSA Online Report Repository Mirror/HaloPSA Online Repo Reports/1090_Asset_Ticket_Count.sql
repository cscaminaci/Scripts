select dinvno as [Asset Tag]
	,(select count(*) from faults where devicenumber=ddevnum and dateoccured>@startdate and dateoccured<@enddate) as [Number of Tickets]

from device
where (select count(*) from faults where devicenumber=ddevnum and dateoccured>@startdate and dateoccured<@enddate) > 0
