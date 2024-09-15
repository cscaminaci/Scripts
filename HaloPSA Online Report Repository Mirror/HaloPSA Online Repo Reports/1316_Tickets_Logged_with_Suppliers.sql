select faultid
,(select cdesc from company where supplier=Cnum) as [Supplier]
,dateoccured
,(select top 1 whe_ from actions where actions.faultid=faults.faultid and Actoutcome like 'Log to Supplier' order by actionnumber) as [DateLoggedToSupplier]
from faults
where fdeleted =0
and FMergedIntoFaultid=0
and supplier is not null
