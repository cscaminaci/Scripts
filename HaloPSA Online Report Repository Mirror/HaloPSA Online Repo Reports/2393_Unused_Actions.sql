select Ooutcome,FHName,isnull(a.fdname,'All Stages') as [FDName]  from flowsubdetail

join toutcome on flowsubdetail.FSDOID=TOUTCOME.Oid
join FLOWHEADER on FLOWSUBDETAIL.FSDFHID = FHID
outer apply(select FDName from flowdetail where  FLOWSUBDETAIL.FSDStartFDSEQ=FDSEQ and FSDStartFDSEQ>0 and FSDFHID=FDFHID)a
