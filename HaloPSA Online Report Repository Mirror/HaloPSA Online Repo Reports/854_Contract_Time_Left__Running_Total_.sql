select
	 Customer
	,ActionDate
	,TicketDescription
	,TicketID
	,ContractID
	,TimeTakenBasic
        ,TimeTakenAdjusted
	,ContractStartDate
	,(select TotalTime - sum(TimetakenAdjusted) from actions where Whe_ >= PeriodDate and Whe_ <= ActionDate and -actions.ActionBillingPlanID-100 = ContractID) as [Time Left]
from 
(
select Top 100 Percent
	 aareadesc as [Customer]
	,(select symptom from faults where faults.faultid=actions.faultid) as [TicketDescription]
	,faultid as [TicketID]
	,CHid as [ContractID]
	,CHstartdate as [ContractStartDate]
	,Whe_ as [ActionDate]
	,case when CHBillingPeriod=1 then dateadd(ww,datediff(ww,chstartdate,Whe_),CHstartdate)
	when CHBillingPeriod=2 then dateadd(mm,datediff(mm,chstartdate,Whe_),CHstartdate)
	when CHBillingPeriod=3 then dateadd(yy,datediff(yy,chstartdate,Whe_),CHstartdate)  
	when CHBillingPeriod=4 then dateadd(mm,floor(datediff(mm,chstartdate,Whe_)/3)*3,CHstartdate) 
	when CHBillingPeriod=5 then dateadd(mm,floor(datediff(mm,chstartdate,Whe_)/6)*6,CHstartdate) 
	when CHBillingPeriod=6 then dateadd(yy,floor(datediff(yy,chstartdate,Whe_)/5)*5,CHstartdate) 
	when CHBillingPeriod=7 then dateadd(yy,floor(datediff(yy,chstartdate,Whe_)/3)*3,CHstartdate) 
	when CHBillingPeriod=8 then dateadd(yy,floor(datediff(yy,chstartdate,Whe_)/2)*2,CHstartdate) 
	else dateadd(yy,floor(datediff(yy,chstartdate,Whe_)/4)*4,CHstartdate) end as [PeriodDate]
	,case when CHBillingPeriod=1 then dateadd(ww,1+datediff(ww,chstartdate,Whe_),CHstartdate)
	when CHBillingPeriod=2 then dateadd(mm,1+datediff(mm,chstartdate,Whe_),CHstartdate)
	when CHBillingPeriod=3 then dateadd(yy,1+datediff(yy,chstartdate,Whe_),CHstartdate)  
	when CHBillingPeriod=4 then dateadd(mm,(1+floor(datediff(mm,chstartdate,Whe_)/3))*3,CHstartdate) 
	when CHBillingPeriod=5 then dateadd(mm,(1+floor(datediff(mm,chstartdate,Whe_)/6))*6,CHstartdate) 
	when CHBillingPeriod=6 then dateadd(yy,(1+floor(datediff(yy,chstartdate,Whe_)/5))*5,CHstartdate) 
	when CHBillingPeriod=7 then dateadd(yy,(1+floor(datediff(yy,chstartdate,Whe_)/3))*3,CHstartdate) 
	when CHBillingPeriod=8 then dateadd(yy,(1+floor(datediff(yy,chstartdate,Whe_)/2))*2,CHstartdate) 
	else dateadd(yy,(1+floor(datediff(yy,chstartdate,Whe_)/4))*4,CHstartdate) end as [PeriodDate2]
	,timetaken as [TimeTakenBasic]
	,timetaken + timetakenadjusted as [TimeTakenAdjusted]
	,CHNumberofUnitsFree as [TotalTime]
from contractheader
left join area on area.aarea = contractheader.charea
left join actions on -actions.ActionBillingPlanID-100 = contractheader.CHid order by aareadesc,Whe_ ) bb 









