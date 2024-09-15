  select aid as ID, afaultid as [Ticket ID],
(select uname from uname where unum=aunum) as [Technician],atablename [Area Changed], avalue as [Field Changed],
afrom as [From], ato as [To] from audit   


