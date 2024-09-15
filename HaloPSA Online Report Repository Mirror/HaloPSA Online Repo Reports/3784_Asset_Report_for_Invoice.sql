select
tdesc as [Category],
dinvno as [Name],
dinactive

from device

join xtype on dtype=ttypenum
join site on dsite=ssitenum
join invoiceheader on ihaarea=sarea and IHid=$invoiceid
join invoicedetail on IdIHid=IHrecurringInvoiceId
join invoicedetailquantity on idid=idqidid and dtype=idqtypeid and dinactive=0
