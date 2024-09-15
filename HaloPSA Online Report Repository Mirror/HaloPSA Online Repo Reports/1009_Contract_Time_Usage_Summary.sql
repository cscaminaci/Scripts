select clientname as [Client], cpnumberofunitsfree as [UnitsFree], round(timeused,2) as [TimeUsed], round(cpnumberofunitsfree-timeused,2) as TimeRemaining from (select (select aareadesc from area where aarea=contractheader.charea) as clientname,
  cpnumberofunitsfree,(select sum(timetaken) from actions inner join faults on actions.faultid=faults.faultid 
  where whe_<@enddate and whe_>@startdate and faults.areaint=contractheader.charea) as timeused from 
  contractheader inner join contractplan on contractheader.chid=contractplan.cpcontractid 
  where chbillingperiod=2 and cpnumberofunitsfree>0 and cpnumberofunitsfree<99999 and chstartdate<@enddate and chenddate>@startdate)a

