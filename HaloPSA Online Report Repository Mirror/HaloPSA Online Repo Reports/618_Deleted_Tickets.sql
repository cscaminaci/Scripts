select aauditid as [Ticket ID],
aauditname as [Subject],
areason as [Deletion Reason],
ausername as [Technician],
adatetime as [Deletion Date]
from auditevent
where Adatetime > @startdate and Adatetime < @enddate
