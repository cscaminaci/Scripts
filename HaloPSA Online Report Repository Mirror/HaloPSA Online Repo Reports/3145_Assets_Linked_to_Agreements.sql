SELECT  
	  (SELECT aareadesc FROM area WHERE charea = aarea) as 'Client'
	, CHcontractRef as 'Contract Reference'
	, (SELECT fvalue FROM lookup WHERE fid = 28 AND fcode = chbillingdescription) as 'Contract Type'
	, dinvno as 'Asset Tag'
	, dinactive as 'Inactive'
	, uusername as 'Username'
	, (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos)as 'Key Field 1'
    , (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos2)as 'Key Field 2'
    , (select idata from info where isite = dsite and inum=ddevnum and iseq=tlabelseqnos3)as 'Key Field 3'
FROM DEVICECONTRACT 
LEFT JOIN CONTRACTHEADER ON DCcontractid = CHid
LEFT JOIN device on did = DCDid
LEFT JOIN USERDEVICE ON UDdevsite = dsite and UDdevnum = ddevnum 
LEFT JOIN users on uduserid = Uid
LEFT JOIN xtype on ttypenum = dtype
LEFt JOIN generic on ggeneric = tgeneric
