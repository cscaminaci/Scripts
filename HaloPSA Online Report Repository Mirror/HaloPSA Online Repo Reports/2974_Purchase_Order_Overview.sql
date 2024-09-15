SELECT
	  SHPORef as 'PO Ref'
	, SH3rdPartyPONumber as '3rd Party Ref'
	, SHtitle as 'Title'
	, SHfaultID as 'Ticket ID'
	, convert(date, SHPODate) as 'Date'
	, (SELECT fvalue FROM lookup WHERE fid = 32 AND fcode = SHUserDefStatus) as 'PO Status'
	, (SELECT cdesc FROM company WHERE SHSupplierID = cnum) as 'Vendor'
	, CASE WHEN SHDeliverToUs = 1 THEN 'Deliver to Us'
		   WHEN SHDeliverToUs = 0 THEN 'Deliver to the User'
	  END AS 'Delivery'
	, (SELECT cast(sum(sdprice * sdquantity) as money) FROM SUPPLIERORDERDETAIL WHERE sdshid = shid) as 'Total Cost'
	, CASE WHEN SHApprovalStatus = 0 THEN 'Needs Approval'
		   WHEN SHApprovalStatus = 3 THEN 'Approval Started'
		   WHEN SHApprovalStatus = 2 THEN 'Approved'
		   WHEN SHApprovalStatus = 1 THEN 'Rejected'
      END as 'Approval Status'
	, SHApprovalRequestDate as 'Date Requested Approval'
	, SHApprovalemailaddr as 'Approver'
	, SHUsername as 'User'
	, sdesc as 'Site'
	, aareadesc as 'Client'
FROM SUPPLIERORDERHEADER
left join users on shuserid=uid
left join site on ssitenum=Usite
left join area on aarea=Sarea
