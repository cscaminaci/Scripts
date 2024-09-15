select QHid AS [Quote ID]

, ISNULL(QHfaultID,0) AS [Ticket ID]
, aareadesc+'/'+sdesc+'/'+uusername AS [Client/Site/User]
, QHDate as [Quotation Date]
, QHtitle as [Quote Heading]
, QHApprovalNote as [Approval Note]
, QHApprovalPONumber as [PO Number]
, QHApprovalDateTime as [Approval Date]
,
round((
select SUM(quotationdetail.qdprice*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Revenue]
,
round((
select SUM(quotationdetail.qdcostprice*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Cost]
,
round((
select SUM((quotationdetail.qdprice - quotationdetail.qdcostprice)*quotationdetail.qdquantity) from quotationdetail
where quotationdetail.qdqhid = qhid and quotationdetail.qditemid != 1
),2) as [Total Profit]

from quotationheader


LEFT JOIN users ON uid=QHuserID


left join QUOTATIONDETAIL on qhid=qdqhid
left join ORDERHEAD on ohqhid=QHid
left JOIN site ON ssitenum=OHSitenum
left JOIN area ON sarea=aarea
left JOIN INVOICEHEADER ON OHid=IHOHid

Group by QuotationHeader.QHid, QuotationHeader.QHfaultID, area.aareadesc, site.sdesc, users.uusername, QuotationHeader.QHDate, QHtitle,QuotationHeader.QHApprovalNote, QuotationHeader.QHApprovalPONumber, QuotationHeader.QHApprovalDateTime



