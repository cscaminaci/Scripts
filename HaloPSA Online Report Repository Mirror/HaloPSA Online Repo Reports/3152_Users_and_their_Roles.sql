select aareadesc [Client], 
sdesc [Site], 
uusername [User], 
URname [User Role] from userrolelink

left join users on uid=urluid
left join userroles on URLurid=urid
left join site on ssitenum=usite
left join area on aarea=sarea
