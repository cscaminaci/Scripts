SELECT 
	  idesc as 'Name'
	, Iaccountsid as 'AccountsID'
	, iid as 'Item ID (Does not change)'
	, ISHAccountsID as 'shaccountsid'
	, idesc3 as 'Description' /*sales description*/
	, idesc4 as 'purchase_description'
	, gdesc as 'Group'
	, idonttrackstock as 'dont_track_stock'
	, icontractitem as 'iscontractitem'
	, IDoesNotNeedConsigning as 'doesnotneedconsigning'
	, (SELECT tdesc FROM xtype WHERE Itypenum = TTypenum) as 'AssetType'
	, Ibaseprice as 'SalesPrice'
	, ICostPrice as 'CostPrice'
	, IIsRecurringItem as 'isrecurringitem'
	, IRecurringPrice as 'recurringprice'
	, irecurringcost as 'irecurringcost'
	, (SELECT cdesc FROM company WHERE cnum = Isupplier) as 'Supplier'
	, idesc2 as 'SupplierPartCode'
	, (SELECT taxdescription FROM tax WHERE TaxID = Itaxcode) as 'taxcode_name'
	, (SELECT taxdescription FROM tax WHERE TaxID = ITaxCodeOther) as 'taxcodeother_name'
	, Inote as 'Notes'
	, INominalCode as 'nominalcode'
	, IPurchaseNominalCode as 'purchasenominalcode'
	, Istatus as 'status' /*14=active 15=obsolete (cannot make other statuses for items currently)*/
	, idontinvoice as 'dontinvoice'
	, IConsignRequestTemplate as 'template_id' /*project template ID*/
FROM item
LEFT JOIN generic on Ggeneric = Igeneric
