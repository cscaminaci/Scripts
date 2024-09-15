 select 
 joid as [Journey_ID],  
 (select uname from uname where unum=jounum) as [Technician],
 jodescription as [Description],  
 jostartdate as [Start_Date],  
 joenddate as [End_Date],
 case when jofaultid=0 then null else jofaultid end as [Ticket_ID]
 
 from journey
