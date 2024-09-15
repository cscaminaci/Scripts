select
did as [ID],
dinvno as [Device Number],
tdesc as [Device Type],
aareadesc as [Customer],
DWarrantyEndDate as [Parts Warranty End Date],
DLabourWarrantyEndDate as [Labour Warranty End Date],
DWarrantyNote as [Warranty Note],
(select LogoutRedirectUri from NHD_IDENTITY_Application where ClientId='24fe0a24-85d5-46d4-b9c6-721e23f25843') as [URL]
from DEVICE
join xtype on dtype=ttypenum
join site on ssitenum=dsite
join area on aarea=sarea
