                select (select uname from uname where unum=clearwhoint) as 'ClosedBy',
faultid as 'TicketID',
symptom as 'TicketSummary',
datecleared as 'DateClosed'
from faults where Status=9      




