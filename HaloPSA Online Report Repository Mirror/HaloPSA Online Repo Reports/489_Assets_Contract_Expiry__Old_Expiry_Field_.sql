select (select aareadesc from area join site on dsite=ssitenum and sarea=aarea) as 'Client'      ,dinvno as
[Asset Tag],(select tdesc from xtype where ttypenum=dtype) as [Asset Type], (select sdesc from site where
dsite=ssitenum) as 'Site'      , (select udusername from userdevice where uddevsite=dsite and uddevnum=ddevnum)
as 'User',      convert(datetime,[idata],103) as 'Contract Expiry Date' from typeinfo join device on dtype=xnum 
join info on xseq=iseq
and isite=dsite and inum=ddevnum and ikind='D' 

where xfieldnos=(select top 1 yseq from field where
ysystemuse=13)

