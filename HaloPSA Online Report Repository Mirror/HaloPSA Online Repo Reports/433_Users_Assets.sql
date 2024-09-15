select uid as [UID],
uusername as [Username],
isnull(uemail,'') as [Email Address], 
aareadesc+' - '+sdesc as [Client/Site],
isnull(dinvno,'NA') as [Asset Tag],
isnull(tdesc,'NA') as [Asset Type],
isnull(gdesc,'NA') as [Asset Group] 
from users 
full join userdevice on udusername=uusername and usite=udsite 
left join device on UDdevnum=ddevnum and UDdevsite=dsite
left join xtype on TTypenum=dtype
left join generic on tgeneric=ggeneric
left join site on ssitenum=usite
left join area on aarea=sarea




