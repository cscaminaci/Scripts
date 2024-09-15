select QHid AS [ID]
	, ISNULL(QHfaultID,0) AS [Ticket ID]
	, aareadesc+'/'+sdesc+'/'+uusername AS [Client/Site/User]
	, QHDate as [Quotation Date]
	, CASE WHEN fvalue = '' THEN 'Not Set' ELSE fvalue END AS [Status]
	, QHExpiryDate as [Expiry Date]
from QuotationHeader
LEFT JOIN users ON uid=QHUserID
LEFT JOIN site ON ssitenum=usite
LEFT JOIN area ON aarea=Sarea
LEFT JOIN lookup ON fid=39 AND fcode=QHstatus
