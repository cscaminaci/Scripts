SELECT TOP 100PERCENT 
  faults.faultid AS [ID], 
  datecleared AS [Date Closed], 
  aareadesc, 
  symptom, 
  sum(
    isnull(ActionChargeHours, 0)
  ) as [ChargeHours],
  '' as [Included Hours]
FROM 
  faults 
  join requesttype on requesttypenew = rtid 
  left join sectiondetail on sectio_ = sdsectionname 
  join actions tobill on tobill.faultid = faults.faultid 
  left join area on aarea = areaint 
  left join site on ssitenum = sitenumber 
  left join users on uid = userid 
where 
  1 = 1 
  and (
    (
      RTIsProject = 0 
      and RTIsOpportunity = 0
    ) 
    or (
      RTIsProject = 1 
      and RTIsOpportunity = 0
    )
  ) 
  and (
    fdeleted is null 
    or fdeleted <> 1
  ) 
  and area.adontinvoice <> 1 
  and (
    status = 9 
    or rtprocessopentickets = 1
  ) 
  and isnull(
    (
      select 
        fvalue7 
      from 
        lookup 
      where 
        fid = 17 
        and fcode =(actioncode + 1)
    ), 
    '0'
  ) <> '1' 
  and tobill.ActIsBillable <> 0 
  and tobill.ActIsReadyForProcessing <> 0
  and isnull(rtisproject, 0)= 0 
  and (
    tobill.ActProcessedDate < 4 
    or tobill.ActProcessedDate is null
  ) 
  and (tobill.ActionChargeHours <> 0) 
group by 
  faults.faultid, 
  dateoccured, 
  symptom,
  datecleared,
  aareadesc
order by 
  datecleared, 
  faults.faultid desc
