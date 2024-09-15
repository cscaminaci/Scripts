select 
apfid [ID]
, nhd_user.username [Name]
, apfdate [Date] 
, CASE
when apfobjecttype=1 then 'Asset'
when apfobjecttype=2 then 'Site'
when apfobjecttype=3 then 'Custom Field'
when apfobjecttype=4 then 'Supplier'
end as [Field Type]
, CASE WHEN apfobjecttype = 1 THEN (SELECT dinvno FROM device WHERE did = apfobjectid)
	   WHEN apfobjecttype = 2 THEN (SELECT sdesc FROM site WHERE ssitenum = apfobjectid)
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 1 THEN concat('Ticket - ', (SELECT faultid FROM faults WHERE faultid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 2 THEN concat('Customer - ', (SELECT aareadesc FROM area WHERE aarea = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 3 THEN concat('Site - ', (SELECT sdesc FROM site WHERE Ssitenum = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 4 THEN concat('User - ', (SELECT uusername FROM users WHERE uid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 5 THEN concat('Asset - ', (SELECT dinvno FROM device WHERE did = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 6 THEN concat('Agreeement - ', (SELECT CHcontractRef FROM contractheader WHERE chid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 7 THEN concat('Action - ', (SELECT faultid FROM faults WHERE faultid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 8 THEN concat('Product - ', (SELECT idesc FROM item WHERE iid= apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 9 THEN concat('Vendor - ', (SELECT cdesc FROM company WHERE Cnum = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 1001 THEN concat('Vendor Agreement - ', (SELECT cncontractcode FROM contract WHERE cnid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 1002 THEN concat('Agent - ', (SELECT uname FROM uname WHERE unum = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 1003 THEN concat('Organisation - ', (SELECT treedesc FROM tree WHERE treeid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 998 THEN concat('PO - ', (SELECT SHPORef FROM SUPPLIERORDERHEADER WHERE shid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 997 THEN concat('Quote - ', (SELECT QHid FROM QUOTATIONHEADER WHERE qhid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 996 THEN concat('Sales Order - ', (SELECT ohid FROM ORDERHEAD WHERE OHid = apfobjectid))
	   WHEN apfobjecttype = 3 AND (SELECT fiusage FROM fieldinfo WHERE fiid = apffieldid) = 995 THEN concat('Invoice - ', (SELECT isnull(IH3rdPartyInvoiceNumber, ihid) FROM INVOICEHEADER WHERE ihid = apfobjectid))
	   WHEN apfobjecttype = 4 THEN 'Supplier Portal Password'
	   ELSE 'Please ask Support to correct this report'
	   END AS 'Entity'
, CASE
when apfobjecttype=1 then 
(select top 1 yname from device join xtype on ttypenum=dtype 
        join typeinfo on ttypenum=xnum 
        join field on ykind='t' and yseq=xfieldnos where xfieldnos=apffieldid)
when apfobjecttype=2 then (SELECT top 1 yname FROM field WHERE yseq = apffieldid AND ykind = 's')
when apfobjecttype=3 then (select filabel from fieldinfo where fiid=apffieldid)
end as [Field]
from auditpasswordfield
join nhd_user on ID=apfnhd_user_id


