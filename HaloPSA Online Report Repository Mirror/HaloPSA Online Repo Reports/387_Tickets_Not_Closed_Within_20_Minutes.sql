select (select uname from uname where unum=assignedtoint)Technician, (select aareadesc from Area where  
aarea=areaint)  as 'Company', dateoccured as [Date Opened],                                                    
                                                               
  faultid as  'TicketNumber',      symptom as  'Summary', category2 as 'Incident type', category3 as 
'Resolution' from faults  where    dateoccured<(datecleared-'00:20:00.000')           



