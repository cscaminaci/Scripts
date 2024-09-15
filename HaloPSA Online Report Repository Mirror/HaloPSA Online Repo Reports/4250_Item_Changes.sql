Select
dcitemid as [Item ID]
,idesc as [Item Name]
,case 
when DCFieldID=-73 then 'Name'
when DCFieldID=-74 then 'Status'
when DCFieldID=-75 then 'Sales Description'
when DCFieldID=-76 then 'Purchase Description'
when DCFieldID=-77 then 'Price'
when DCFieldID=-78 then 'Cost'
when DCFieldID=-79 then 'Sales Tax'
when DCFieldID=-81 then 'Group'
when DCFieldID=-90 then 'Is Taxable'
else cast(DCFieldID as nvarchar) end as [Field]
,DCWho as [Agent] 
,DCWhen as [Date]
, case 
when DCFieldID=-74 and DCOldValue=14 then 'Obsolete'
when DCFieldID=-74 and DCOldValue=15 then 'Active'
else cast(DCOldValue as nvarchar) end as [From]
, case 
when DCFieldID=-74 and DCNewValue=14 then 'Obsolete'
when DCFieldID=-74 and DCNewValue=15 then 'Active'

else cast(DCNewValue as nvarchar) end as [To]

from devicechange
left join item on dcitemid=iid
where dcitemid>0
