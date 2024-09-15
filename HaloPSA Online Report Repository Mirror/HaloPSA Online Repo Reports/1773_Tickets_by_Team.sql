select sectio_ as [Team],count(*) as [Count] from faults 

where fdeleted=0 and @startdate<dateoccured and @enddate>dateoccured
group by sectio_
