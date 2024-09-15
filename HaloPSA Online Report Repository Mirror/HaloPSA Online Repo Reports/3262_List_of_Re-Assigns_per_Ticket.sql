select distinct
faultid as [Ticket ID],
sdsectionname as [Team Re-Assigned To],
uname as [Agent Re-Assigned To]
from resourcetimelog
join faults on rtlfaultid=faultid
left join sectiondetail on sdsectionname=rtlsection
left join uname on unum=rtlunum
where rtlenddate between @startdate and @enddate

