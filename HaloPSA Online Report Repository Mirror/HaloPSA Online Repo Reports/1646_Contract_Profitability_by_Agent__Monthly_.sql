select 
	  [Customer]
        , [Contract Type]
        , [Agent]
	, isnull(round(sum([Monthly Revenue]),2),0) as [Monthly Revenue (£)]
	, [Average Monthly Cost (Last 12 Months) (£)]
	, isnull(round(sum([Monthly Revenue]),2),0) - [Average Monthly Cost (Last 12 Months) (£)] as [Average Monthly Profit (£)]
	, round(((isnull(round(sum([Monthly Revenue]),2),0) - [Average Monthly Cost (Last 12 Months) (£)])/nullif(round(sum([Monthly Revenue]),2),0))*100,2) as [Profitability (%)]
from
(select
	  aareadesc as [Customer]
        , fvalue as [Contract Type]
        , uname as [Agent]
	, case when CHBillingPeriod=1 then CHPeriodChargeAmount*52/12 
		   when CHBillingPeriod=2 then CHPeriodChargeAmount
		   when CHBillingPeriod=3 then CHPeriodChargeAmount/3
		   when chbillingPeriod=4 then CHPeriodChargeAmount/6
		   when CHBillingPeriod=5 then CHPeriodChargeAmount/12
		   when CHBillingPeriod=6 then CHPeriodChargeAmount/24
		   when chbillingperiod=7 then CHPeriodChargeAmount/36
		   when chbillingperiod=8 then CHPeriodChargeAmount/48
		   when chbillingperiod=9 then CHPeriodChargeAmount/60
		else 0
		end as [Monthly Revenue]
	, isnull(round(sum(timetaken*ucostprice)/12,2),0) as [Average Monthly Cost (Last 12 Months) (£)]
from area
left join contractheader on charea=aarea
left join faults on aarea=areaint and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) and fcontractid>0
left join actions on actions.faultid=faults.faultid
left join uname on whoagentid=unum
left join lookup on fid=28 and chbillingdescription=fcode
where chstatus=3
group by aareadesc,chbillingperiod,CHPeriodChargeAmount,fvalue,uname)z
group by [Customer],[Average Monthly Cost (Last 12 Months) (£)],[Contract Type],[Agent]


