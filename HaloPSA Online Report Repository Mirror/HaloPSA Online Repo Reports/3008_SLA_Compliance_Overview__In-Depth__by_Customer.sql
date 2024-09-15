select faultid,  (select aareadesc from area where areaint=aarea)CustomerName,  (select sdesc from site where
ssitenum=sitenumber)Site,  username as EndUser,  dateoccured as 'Date Occurred',   (select uname from
uname where  assignedtoint=unum)Tech,    (select tstatusdesc from tstatus where status=tstatus)Status,   
symptom 
as Summary,     SLAHold=case  when fslaonhold=1 then 'On Hold'  else 'Not On Hold'  end ,   
FixByDateStatus=case       when  fexcludefromsla='true' then 'Excluded'   when fixbydate<GETDATE() then 
'Breached'    when GETDATE()<fixbydate  then 'Not Breached'     end,   FixBydate as 'Target Fix', 
frespondbydate as 'Target Response', fresponsetime as  'ResponseTime(hrs)', fresponsedate as 'Actual 
Response', 
datecleared as 'Actual Fix', (select pdesc from policy where seriousness=ppolicy and slaid=pslaid)as 
'Priority', Compliance=case when fexcludefromsla='true' then 'Excluded' when fixbydate<datecleared then 
'Outside'  when datecleared<fixbydate then 'Inside' else 'Open' end, round(cleartime,2) as 'Hours Used', 
round(FSLAholdtime,2) as 'Hours Held' from faults                                                              
  
