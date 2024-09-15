  SELECT TOP 100PERCENT 
cast('Contract Prepay (Overage)' as nvarchar) as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where (ActionBillingPlanID*-1)-100=chid) AS [Contract], 
  whe_ as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
    isnull(ActionChargeHours, 0)
   as [ChargeHours]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
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
  and tobill.actionchargehours<>0
     and tobill.ActReviewed='False'

     and whe_ between @startdate and @enddate
     and (select CHcontractRef from contractheader where fcontractid=chid) is NOT null

     

UNION



SELECT TOP 100PERCENT 
'Non Contract/Prepay' as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where fcontractid=chid) AS [Contract], 
  whe_ as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
    isnull(ActionChargeHours, 0)
   as [ChargeHours]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
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
  and tobill.actionchargehours<>0
     and tobill.ActReviewed='False'

     and whe_ between @startdate and @enddate
     and (select CHcontractRef from contractheader where fcontractid=chid) is null


UNION


SELECT TOP 100PERCENT 
'No Charge' as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where fcontractid=chid) AS [Contract], 
  whe_ as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
    isnull(ActionChargeHours, 0)
   as [ChargeHours]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
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
  and tobill.ActionCode+1=0
  and tobill.timetaken>0
     and tobill.ActReviewed='False'

     and tobill.whe_ between @startdate and @enddate


UNION


SELECT TOP 100PERCENT 
'Contract/Prepay (Included)' as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where (ActionBillingPlanID*-1)-100=chid) AS [Contract], 
  whe_ as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
    isnull(timetaken, 0)
   as [ChargeHours]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
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
  and tobill.timetaken>0
     and tobill.ActReviewed='False'
     and tobill.ActionChargeHours in (-0,0,null)
     and tobill.whe_ between @startdate and @enddate
     and  (ActionBillingPlanID*-1)-100 in (select chid from contractheader)
