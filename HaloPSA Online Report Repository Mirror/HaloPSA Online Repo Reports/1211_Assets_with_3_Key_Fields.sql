select 
       aareadesc as [Client],
       sdesc as [Site],
       (select top 1 udusername from userdevice where uddevnum=ddevnum and uddevsite=dsite) as [User],
	   gdesc as [Asset Group],
	   tdesc as 'Asset Type',
       dinvno as [Asset Tag],
       (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos)as 'Key Field 1',
       (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos2)as 'Key Field 2',
       (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos3)as 'Key Field 3'
from device
join xtype on ttypenum = dtype
join site on ssitenum = dsite
join area on aarea = sarea
join generic on ggeneric = tgeneric
