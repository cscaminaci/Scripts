SELECT distinct
	  SHPORef as 'PO'
	, SH3rdPartyPONumber as '3rd Party Ref'
	, SHtitle as 'Title'
	, SHfaultID as 'Ticket ID'
	, SHPODate as 'Date'
	, SDDesc as 'Item Description'
	, idesc2 as 'Item'
	, (SELECT fvalue FROM lookup WHERE fid = 32 AND fcode = SHUserDefStatus) as 'Status'
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
	, SHdatesent as 'Date Sent'
	, SHApprovalemailaddr as 'Approver'
	, SHUsername as 'User'
	, sdesc as 'Site'
	, aareadesc as 'Client'
	, olid as 'SO'
	, (select uname from uname where unum=SHCreatedBy) as 'Created by'
FROM SUPPLIERORDERHEADER
left join supplierorderdetail on SDSHid=Shid
left join orderline on SHid=OLSupplierPO
left join users on shuserid=uid
left join site on ssitenum=Usite
left join area on aarea=Sarea
left join item on iid=SDItemid
