select apid as 'Report_ID',

apdesc as 'Report_Description',

stdemailto as 'Email_To',

stdemailcc as 'Email_CC',

stdemailsubject as 'Email_Subject',

stdlastcreated as 'Last_Creation_Date',

stdnextcreationdate as 'Next_Creation_Date' ,

(select fvalue from lookup where fid=41 and apgroupid+1=fcode) [Report Group]

from stdrequest join analyzerprofile on stdapid=apid
