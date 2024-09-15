select (select aareadesc from area join site on dsite=ssitenum and sarea=aarea) as 'Client'      , (select sdesc
from site where dsite=ssitenum) as 'Site'      , (select top 1 udusername from userdevice where uddevsite=dsite
and  uddevnum=ddevnum) as 'User',      dwarrantyenddate as 'Contract Expiry Date',(select tdesc from xtype where
 ttypenum=dtype) as 'Type', (Select idata from info where ikind='d' and isite=dsite and inum=ddevnum and         
                                                                                                                 
                                                                   iseq=(select xseq from typeinfo where 
xnum=dtype and xfieldnos=(select yseq from field where yname ='Name')))Name from  device 


