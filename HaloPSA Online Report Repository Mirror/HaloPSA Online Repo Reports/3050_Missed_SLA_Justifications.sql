select  sectio_ as [Team],  
faultid as [Ticket ID],  
(select rtdesc from requesttype where requesttypenew=rtid)as [Form Logged],  
replace(replace(replace((slastate),'I','SLA Met'),'O','SLA Missed'),'X','SLA Excused') as [SLA Met?],  
isnull((slareason),'N/A') as [Justification],                                                   
(datecleared) as [Date Closed]
  from faults  
where fexcludefromsla=0     and status=9 and slastate in ('O','X')
