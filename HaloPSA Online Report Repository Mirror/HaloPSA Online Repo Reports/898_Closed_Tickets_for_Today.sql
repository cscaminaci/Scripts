select uname as [Technician Name], faultid as [Ticket ID], aareadesc as [Client Name], symptom as [Description] from faults
left join uname on unum = clearwhoint
left join area on aarea = areaint 
where status = 9 and cast(datecleared as date) = cast(getdate() as date) 

