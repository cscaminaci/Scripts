SELECT 
	  ohid as [ID]
	, OHtitle as [Title]
	, OHorderdate as [Date]
	, OHusername as [User]
	, OHshipdate as [Ship Date]
	, (select fvalue from lookup where fid = 34 and fcode = ohuserstatus) as [Status]
	, OHInvoiceDate as [Invoice Date]
	, round(OLSellingPrice*OLorderqty,2) as [Revenue]
	, round(OLCostPrice*olorderqty,2) as [Cost]
	, round(round(OLSellingPrice*OLorderqty,2) - round(OLCostPrice*olorderqty,2),2) as [Profit]
	, isnull(round(OLSellingPrice*OLorderqty/(SELECT sum(idnet_amount) FROM invoicedetail WHERE IDOLID = olid)*100,2),0) as [% Invoiced]
	, (SELECT uname FROM uname WHERE OHCreatedBy = unum) as 'Created By'
	, OHnote as 'Notes'
FROM orderhead
JOIN orderline on ohid=olid
JOIN site on ohsitenum=ssitenum
join area on aarea=sarea
