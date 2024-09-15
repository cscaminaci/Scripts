select count(faultid) as 'Total Requests Logged', (select count(faultid) from faults where status=9)as 'Total Cleared', (select avg(cleartime) from faults where status=9)as 'Avg. Clear Time'   from faults     

