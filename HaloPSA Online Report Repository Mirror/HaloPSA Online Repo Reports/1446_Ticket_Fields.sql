select rtdesc as [Ticket]
,(select fvalue from lookup where fid=21 and fcode=RTRequestType) as [Ticket Type]
,FILabel as [Field Name]
,case when FILookup>1 then  (SELECT fvalue + CHAR(13)
        FROM LOOKUP
        WHERE fid=FILookup
        ORDER BY fcode 
        FOR XML PATH (''), TYPE
    ).value('.', 'varchar(max)') 
else 'N/A' end as [Dropdown Values]
,case when FDEndUserNew=0 then 'Hidden' when FDEndUserDetail=1 then 'Visible - Not Required' when FDEndUserDetail=2 then 'Visible - Warn if Empty' when FDEndUserDetail=3 then 'Visible - Required' end as [User Visibility]
,case when FDTechNew=0 then 'Hidden' when FDTechNew=1 then 'Visible - Not Required' when FDTechNew=2 then 'Visible - Warn if Empty' when FDTechNew=3 then 'Visible - Required' end as [Agent Visibility]
from FIELDDISPLAY
join requesttype on FDRTid=RTid
join FIELDINFO on FDFieldID=FIid
