SELECT isnull(aareadesc,'') as 'Client'
, isnull(cast((select case when apfaultid=0 then null else apfaultid end) as nvarchar),'')as 'Ticket Number'
, APSubject as 'Description'
, convert(varchar(16),Apstartdate,120) as 'Appointment Date/Time'
, (select round(cast(datediff(mi,apstartdate,apenddate) as float)/60, 2)) as 'Appointment Duration (Hrs)'
,(select fvalue from lookup where fid=63 and fcode=apappointmenttype) as [Appointment Type]
, Uname as 'Technician'
from appointment 
left join faults on faults.faultid=apfaultid
left join area on areaint=aarea
join uname on unum=apunum
where apstartdate>@startdate and apstartdate<@enddate and (datecleared>@startdate and datecleared<@enddate) or (dateoccured>@startdate and dateoccured<@enddate)




