select
(select aareadesc from area where aarea=sarea) as 'Client Name',
sarea as 'Client ID',
sdesc as 'Site Name',
ssitenum as 'site_id',
(select top 1 Asdescription from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'Description',
(select top 1 Asline1 from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'Line1',
(select top 1 Asline2 from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'Line2',
(select top 1 Asline3 from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'Line3',
(select top 1 Asline4 from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'Line4',
(select top 1 Asline5 from addressstore where AddressStore.assiteid = ssitenum order by asid desc) as 'PostCode'
from Site 
where sisinactive='False' and sarea not in (123,97,165,1) and sarea not in (select aarea from area where aisinactive='True')

