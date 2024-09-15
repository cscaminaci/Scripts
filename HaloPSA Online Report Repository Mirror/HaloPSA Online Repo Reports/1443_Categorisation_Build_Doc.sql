select 
case when cdtype=2 then (select filabel from FIELDINFO where fiid=5)
when cdtype=3 then (select filabel from FIELDINFO where fiid=6)
when cdtype=4 then (select filabel from FIELDINFO where fiid=7)
when cdtype=5 then (select filabel from FIELDINFO where fiid=8)
end as [Category Type]
,cdcategoryname as [Category Value] 

from categorydetail
