 select
       (select tdesc from xtype where ttypenum = dtype) as 'Asset Type',
       (select sdesc from site where ssitenum = dsite) as 'Site',
       DWarrantyEndDate,
       (select idata from info where isite = dsite and inum=ddevnum and iseq=(select xseq from typeinfo where
xfieldnos=131 and xnum=dtype))as 'Main Number',
       (select idata from info where isite = dsite and inum=ddevnum and iseq=(select xseq from typeinfo where 
xfieldnos=132 and xnum=dtype))as 'IMEI Number'
from device
                         


