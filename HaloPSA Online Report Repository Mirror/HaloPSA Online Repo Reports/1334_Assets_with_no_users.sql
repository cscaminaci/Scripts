select dinvno 

from device 
where ddevnum not in (
select uddevnum from userdevice
)


