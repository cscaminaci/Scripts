 select
(select aareadesc from area where aarea=sarea) as [Client],
sdesc as 'Name',
(select idata from info where iseq=1 and inum=ssitenum and ikind='S') as 'Address1',
(select idata from info where iseq=2 and inum=ssitenum and ikind='S') as 'Address2',
(select idata from info where iseq=3 and inum=ssitenum and ikind='S') as 'Address3',
(select idata from info where Iseq in (select yseq from field where ysystemuse=4) and Ikind='S' and Isite = 0 and Inum = ssitenum ) as 'Post Code/Zip',
sgeocoord1,
sgeocoord2
from site
