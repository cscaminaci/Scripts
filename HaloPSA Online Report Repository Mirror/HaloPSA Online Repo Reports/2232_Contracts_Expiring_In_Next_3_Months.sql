select
aareadesc as 'Customer',
(chstartdate) as 'StartDate',
(chenddate) as 'EndDate',
(select fvalue from lookup where chstatus=fcode and fid=38) as [Contract Status],
(chperiodchargeamount) as 'Period Amount',
replace(replace(replace(replace((chbillingperiod),1,'Weekly'),2,'Monthly'),3,'Yearly'),4,'Quarterly') as 'Period',
(select fvalue from lookup where fid=28 and fcode=(chbillingdescription)) as 'Billing Description'
from Area inner join contractheader on charea=aarea
where @startdate<chenddate and chenddate<@enddate
                                                                       


