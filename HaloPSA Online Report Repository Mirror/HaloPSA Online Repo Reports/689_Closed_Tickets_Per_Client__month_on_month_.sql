select
         (select aareadesc from area where aarea=faults.areaint) as [Clients]
       , count(b.faultid) as [Current Month -5]
       , count(d.faultid) as [Current Month -4]
       , count(f.faultid) as [Current Month -3]                            
       , count(h.faultid) as [Current Month -2]
       , count(j.faultid) as [Current Month -1]
       , count(l.faultid) as [Current Month]

from faults left join 

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults 
where status=9 and datecleared > getdate()-200
)a where month = datepart(mm,dateadd(month,-5,getdate())))b  on faults.faultid=b.faultid left join

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults
where status=9 and datecleared > getdate()-200       
)c where month = datepart(mm,dateadd(month,-4,getdate())))d  on faults.faultid=d.faultid left join

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults
where status=9 and datecleared > getdate()-200
)e where month = datepart(mm,dateadd(month,-3,getdate())))f  on faults.faultid=f.faultid left join

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults
where status=9 and datecleared > getdate()-200
)g where month = datepart(mm,dateadd(month,-2,getdate())))h  on faults.faultid=h.faultid left join

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults
where status=9 and datecleared > getdate()-200
)i where month = datepart(mm,dateadd(month,-1,getdate())))j  on faults.faultid=j.faultid left join

(select * from
(select areaint, faultid, 
(select date_month from calendar where convert(date,datecleared) = date_id) as [Month]  
from faults
where status=9 and datecleared > getdate()-200
)k where month = datepart(mm,getdate()))l  on faults.faultid=l.faultid

group by faults.areaint
                          


