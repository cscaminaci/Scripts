select uusername as [Username]
,uextn as [Phone Number]
,uemail as [Email]
,aareadesc as [Client] 
,sdesc as [Site] 
from users 
join site on usite=ssitenum 
join area on aarea=sarea
where uquestion1 in (NULL,'',0) and uanswer1 in (NULL,'',0)
and uusername <> 'General User'
