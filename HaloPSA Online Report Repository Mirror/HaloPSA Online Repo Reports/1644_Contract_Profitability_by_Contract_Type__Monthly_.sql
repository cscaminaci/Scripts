select 
[Contract Type],
sum([Monthly Revenue (£)]) as [Monthly Revenue (£)],
sum([Average Monthly Cost (Last 12 Months) (£)]) as [Average Monthly Cost (Last 12 Months) (£)],
sum([Average Monthly Profit (£)]) as [Average Monthly Profit (£)],
avg([Profitability (%)]) as [Profitability (%)]

from(
select 
	  [Contract Type]
      
	, isnull(round(sum([Monthly Revenue]),2),0) as [Monthly Revenue (£)]
	, [Average Monthly Cost (Last 12 Months) (£)] as [Average Monthly Cost (Last 12 Months) (£)]
	, round(isnull(sum([Monthly Revenue]),0) - [Average Monthly Cost (Last 12 Months) (£)],2) as [Average Monthly Profit (£)]
	, round(((isnull(round(sum([Monthly Revenue]),2),0) - [Average Monthly Cost (Last 12 Months) (£)])/nullif(isnull(round(sum([Monthly Revenue]),2),0),0))*100,2) as [Profitability (%)]
from
(select
	  b.fvalue as [Customer Type]
        , a.fvalue as [Contract Type]
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
left join lookup b on fid=33 and fcode=acustomertype
left join contractheader on charea=aarea
left join faults on aarea=areaint and requesttypenew in (select rtid from requesttype where rtisproject=0 and rtisopportunity=0) and fcontractid>0
left join actions on actions.faultid=faults.faultid
left join uname on whoagentid=unum
left join lookup a on a.fid=28 and chbillingdescription=a.fcode
where chstatus=3
group by b.fvalue,chbillingperiod,CHPeriodChargeAmount,a.fvalue
)z
group by [Contract Type],[Average Monthly Cost (Last 12 Months) (£)]
)zz
group by [Contract Type]


