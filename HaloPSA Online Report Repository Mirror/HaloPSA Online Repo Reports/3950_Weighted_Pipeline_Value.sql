select

count (faultid) as [Number of Projects],
uname as [Account Manager],
convert(varchar(7), FOppTargetDate, 23) as [Target Date],
/*rtdesc as [Opportunity Type],*/
sum(foppvalue) as [Total Project Value],
/*FOppConversionProbability,*/
ROUND(sum(foppvalue * FOppConversionProbability*1.0/100),2)  as [Weighted Project Value]


from faults 

join uname on faults.assignedtoint = uname.unum
join requesttype on faults.requesttypenew = requesttype.rtid

where foppvalue > 0
and status not in (8,9)
and fdeleted = 0


group by uname, convert(varchar(7), FOppTargetDate, 23)/*, rtdesc, FOppConversionProbability*/
