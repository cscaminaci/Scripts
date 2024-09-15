select 	 
 
sectio_ as [Team]
,isnull(sum(inside),0) as [First Contact Resolution]
,count(*) as [Resolved Tickets]
,isnull(round(100*sum(inside)/cast(count(*) as float),2),0) as [% Inside]
		  from faults
left join (select 1 inside,faultid insidefid from faults) inside on faultid=insidefid and (datepart(dd,dateoccured)>datepart(dd,datecleared)-1)
		 
where fdeleted=fmergedintofaultid and status in (8,9) and requesttypenew not in (5,20,79) and dateoccured between @startdate and @enddate

group by sectio_
