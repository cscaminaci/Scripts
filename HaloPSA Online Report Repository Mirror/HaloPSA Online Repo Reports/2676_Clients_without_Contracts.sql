select 

aareadesc as [Client], 
aarea as [Client ID] 

from area where aarea not in  (select charea from contractheader)
