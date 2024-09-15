select top 10000
RTFRTid
,RTFID
,rtdesc as [Ticket Type]
,RTFFieldId as [Field ID]
,iif(FI1.filookup < 1, null,FI1.filookup) as [Lookup ID]
,FI1.FIName as [Field DB Name]
,FI1.FIHint as [Hint]
,FI1.FILabel as [Shown Name]
,FI1.FIType
, case when FI1.FIType = '0' then 'Text'
       when FI1.FIType = '1' then 'Memo'
       when FI1.FIType = '2' then 'Single Select'
       when FI1.FIType = '3' then 'Multi Select'
       when FI1.FIType = '4' then 'Date'
       when FI1.FIType = '5' then 'Time'
       when FI1.FIType = '6' then 'CheckBox'
       when FI1.FIType = '10' then 'Rich' 
end as [Field Type]
, [Values]
, [Visibility]
, case when rtfendusernew like '0' then 'Not visibile'
       when rtfendusernew like '1' then 'visibile - Not Required'
       when rtfendusernew like '2' then 'visibile - Warning'
       when rtfendusernew like '3' then 'Required'
  else 'Read Only' end as [End User Visibility]
, case when rtftechnew like '0' then 'Not visibile'
       when rtftechnew like '1' then 'visibile - Not Required'
       when rtftechnew like '2' then 'visibile - Warning'
       when rtftechnew like '3' then 'Required'
  else 'Read Only' end as [Agent Visibility]
, FI2.FIName as [Visibility Field Dependency]
from requesttypefield

join requesttype on RTFRTID = rtid
join fieldinfo FI1 on RTFFieldId = FI1.fiid

outer apply (SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(fvalue,'N/A')), ',') AS 'Values'
FROM lookup where fid = FI1.filookup)[Values]

outer apply (SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(CFVLookupValue,'N/A')), ',') AS 'Visibility', CFVLookupFieldid FROM customfieldvisibility where FI1.fiid = CFVFieldid and CFVfieldidvalue = -1 group by CFVLookupFieldid , CFVLookupValue,CFVFieldid)[DependentFieldVisibility]

left Join Fieldinfo FI2 on [DependentFieldVisibility].CFVLookupFieldid = fi2.fiid

order by RTFid asc
