select (select tdesc from xtype where dtype=ttypenum) as [Asset Type],
(select sdesc from site where ssitenum=dsite) as [Site],
dinvno as [Asset Tag],
(select top 1 uusername from users where UisContractContact=1 and usite = dsite) as [Contact],
(select top 1 uemail from users where UisContractContact=1 and usite = dsite) as [Contact Email],
(select top 1 uextn from users where UisContractContact=1 and usite = dsite) as [Contact Phone]
from device

