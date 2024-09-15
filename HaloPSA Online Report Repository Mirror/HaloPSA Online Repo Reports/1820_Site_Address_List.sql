select 
treedesc as 'Top Level',
aareadesc as 'Client Name',
aarea as 'Client ID',
sdesc as 'Site Name',
Asdescription as 'Address Name',
Asline1 as 'Line 1',
Asline2 as 'Line 2',
ASLine3 as 'Line 3',
ASLine4 as 'Line 4',
Asline5 as 'Post Code'
from Site join area on sarea=aarea
join tree on treeid=atreeid
left Join AddressStore on AddressStore.assiteid = ssitenum
where isnull(sisinactive,0)<>1 and isnull(AIsInactive,0)<>1 and isnull(ASInActive,0)<>1

