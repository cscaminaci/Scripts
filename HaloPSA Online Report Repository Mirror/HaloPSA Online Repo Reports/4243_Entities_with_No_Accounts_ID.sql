select
 'Recurring Invoice Line' as [Type]
,-9-idihid [ID]
, aareadesc [Client]
, IDItem_ShortDescription [Description]
, IDNominal_Code [Accounts ID]
from invoicedetail
join invoiceheader on ihid=idihid
join area on aarea=ihaarea
where idihid<0

union

select
'Item' as [Type]
,iid as [ID]
, null as [Client]
, idesc as [Description]
, inominalcode [Accounts ID]
from item

union

select
 'Client' as [Type]
, aarea as [ID]
, aareadesc as [Client]
, aareadesc as [Description]
, aaccountsid as [Accounts ID]
from area
where aarea not in (12,1) and aisinactive='False'
