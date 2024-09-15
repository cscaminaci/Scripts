select 
ldesc as [License],
Lcount as [Quantity],
aareadesc as [Customer],
lcfieldid as [Field Changed ID],
lcoldvalue as [Old Value],
lcnewvalue as [New Value],
lcwhen as [Date of Change]
 from Licence
join LicenceChange on lid=lclid
join area on aarea=larea
