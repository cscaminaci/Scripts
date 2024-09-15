select 
aareadesc as [Customer],
dinvno as [Device],
did as [Device ID],
ihid as [Invoice ID],
IDPRDate as [Change Date],
IDPRShortDescription as [Description],
IDPRQuantity as [Quantity of Change]
 from InvoiceDetailProRata
join invoicedetail on idid=idpridid
join invoiceheader on ihid=idihid
join area on aarea=ihaarea
join device on did=IDPRDeviceId
where IDPRDeviceId>0
