select 
	(select aareadesc from area where areaint = aarea) as [Client],
	(select sdesc from site where ssitenum = sitenumber) as [Site],
	dinvno as [Asset],
	(select idata from info where isite = dsite and inum=ddevnum and iseq=(select xseq from typeinfo where xfieldnos=51 and xnum=dtype))as [Serial Number],
	category2 as [Category],
	count(faultid) as [Count of Tickets]
from faults
left join device on devicenumber = did
where datecleared > @startdate and datecleared < @enddate and status = 9 and fdeleted=0
group by areaint,sitenumber,dinvno,category2,dtype,dsite,ddevnum
