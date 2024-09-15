SELECT
DInvNo AS [AssetTag],
TDesc AS [DeviceType],
SDesc AS [SiteName],
(SELECT AAreaDesc FROM Area WHERE SArea = AArea) AS [CustomerName],
DStatus AS [Status_ID]

FROM Device
LEFT JOIN XType ON TTypeNum = DType
LEFT JOIN Site ON DSite = SSiteNum
