select 
did as [AssetID]
,dinvno as [AssetTag]
,dreservedolid as [ReservedOn] 
,(select LogoutRedirectUri from NHD_IDENTITY_Application where ClientId='24fe0a24-85d5-46d4-b9c6-721e23f25843') as [URL]
from device 
where dreservedolid>0 and dinactive=0

