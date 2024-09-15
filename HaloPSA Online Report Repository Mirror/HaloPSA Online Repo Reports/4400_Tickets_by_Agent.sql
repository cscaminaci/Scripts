SELECT * from (select
      uname as [Agent]
    , sum(iif(status<>9 and dateoccured between @startdate and @enddate, 1,0)) as [Open]
    , sum(iif(status=9 and datecleared between @startdate and @enddate,1,0)) as [Resolved]
    from faults 
    join uname on unum=assignedtoint
    join requesttype on rtid=requesttypenew 

    where fdeleted=0 and rtisproject=0 and rtisopportunity=0

    group by uname)a

    where [Open]>0 or [Resolved]>0
