select QHid AS [ID]
	, ISNULL(QHfaultID,0) AS [Ticket ID]
	, aareadesc+'/'+sdesc+'/'+uusername AS [Client/Site/User]
	, QHDate as [Quotation Date]
	, QHApprovalNote as [Approval Note]
	, QHApprovalPONumber as [PO Number]
	, QHApprovalDateTime as [Approval Date]
from QuotationHeader
LEFT JOIN users ON uid=QHUserID
LEFT JOIN site ON ssitenum=usite
LEFT JOIN area ON aarea=Sarea
WHERE QHStatus=1
