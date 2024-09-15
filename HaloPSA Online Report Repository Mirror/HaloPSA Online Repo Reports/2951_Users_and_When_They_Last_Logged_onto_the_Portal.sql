select uemail as Email , ulastlogindate as 'Last Login Date' from users 
where ulastlogindate is not null 
  AND ulastlogindate != ''
  and uemail is not null 
  AND uemail !=''
