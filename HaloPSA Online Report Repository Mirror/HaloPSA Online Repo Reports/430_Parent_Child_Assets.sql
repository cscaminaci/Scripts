select aareadesc as [Client], sdesc as [Site],
(select tdesc from xtype where ttypenum = d.dtype) as [Asset Type],
(select idata from info where ikind='d' and  isite = d.dsite and inum=d.ddevnum and iseq=(select xseq from 
typeinfo where xfieldnos=101 and xnum=d.dtype))as [Description],
(select idata from info where ikind='d' and isite = d.dsite and inum=d.ddevnum and iseq=(select xseq from 
typeinfo where xfieldnos=117 and xnum=d.dtype))as [Custom Serial Number],
dinvno as [Asset Tag],
d.did as [Device ID],
case when d.dparentdid>0 then 'Child' when (select count(did) from device where DParentDid=d.did and d.did<>0)=0 
then 'NA'  else 'Parent' end as [Parent/Child],               
case when d.dparentdid=0 then 'Asset ID '+cast(d.did as nvarchar(255)) else 'Asset ID '+cast(d.dparentdid as
nvarchar(255)) end as [Parent Device ID],
case when d.dparentdid=0 then (select tdesc from xtype where ttypenum = d.dtype) else (select tdesc from xtype where ttypenum = (select dtype from device 
where did=d.dparentdid)) end as [Parent Type]
from                                                         
area join site on sarea=aarea join device d on dsite=ssitenum

