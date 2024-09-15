select

chid as 'Contract ID',

chcontractref as 'Reference',

(select aareadesc from area where aarea=charea) as 'Client Name',

(case

when chbillingperiod=1 then 'Weekly'

when chbillingperiod=2 then 'Monthly'

when chbillingperiod=3 then 'Yearly'

when chbillingperiod=4 then 'Quarterly'

when chbillingperiod=5 then '6 Monthly'

else 'N/A'

end) as 'BillingPeriod',

(select fvalue from lookup where fid=28 AND fcode=chbillingdescription) as 'Contract Type',

(select fvalue from lookup where fid=38 and fcode=chstatus) as 'Contract Status',

CHstartdate as 'Start Date',

CASE 
WHEN CHenddate > cast('2099-01-01' as date) then 'Unlimited'
else cast(CHenddate as nvarchar)
end as 'End Date'

from contractheader
