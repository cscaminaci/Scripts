select
      faultid as [Ticket ID]
    , symptom as [Summary]
    , dateoccured as [Date/Time Logged]
    , convert(date,dateoccured) as [Date Logged]
    , convert(varchar, dateoccured, 8) as [Time Logged]
    , (select aareadesc from area where aarea=areaint) as [Organisation]
    , sdesc as [Site]
    , username as [User]
    , sectio_ as [Team]
    , (select pdesc from policy where ppolicy=seriousness and pslaid=slaid) as [Priority]
    , (select uname from uname where assignedtoint=unum) as [Assigned To]
    , stdesc as [Service]
    , category2 as [Category]
    , (select tstatusdesc from tstatus where status=tstatus) as [Status]
    , devicenumber as [Linked Asset]
    , flastactiondate as [Last Action]
    , CASE WHEN slastate='I' THEN 'Inside' WHEN slastate='O' THEN 'Outside' END as [SLA Compliance]
    , (select uname from uname where clearwhoint=unum) as [Resolved By]
    , datecleared as [Date/Time Resolved]
    , convert(date,datecleared) as [Date Resolved]
    , convert(varchar, datecleared, 8) as [Time Resolved]
    , round(fresponsetime,2) as [Response Time]
    , round(elapsedhrs,2) as [Fix Time] 
    , clearance as [Resolution Notes]
    , category3 as [Closure Code]
    , case when satisfactionlevel=1 then 'Excellent'
           when satisfactionlevel=2 then 'Good'
           when satisfactionlevel=3 then 'OK'
           when satisfactionlevel=4 then 'Bad' end as [Feedback Score]
    , satisfactioncomment as [Feedback Comment]
    , (select cdesc from company where supplier=cnum) as [Supplier]
    , suppref as [Supplier Ticket ID]
    , (select rtdesc from requesttype where rtid=requesttypenew) as [Type]
    , CASE 
	WHEN (SELECT useriousnesslevel FROM USERS WHERE userid = uid) = 2 THEN 1
	ELSE 0
      END as [VIP]
    , fFirstTimeFix as [First Time Fix]
from faults 
join site on site.ssitenum=faults.sitenumber
left join faultservice on fsfaultid = faultid
left join servsite on fsstid = stid
where
      fdeleted = 0
  and fmergedintofaultid = 0
  and requesttype in (1,3)




















