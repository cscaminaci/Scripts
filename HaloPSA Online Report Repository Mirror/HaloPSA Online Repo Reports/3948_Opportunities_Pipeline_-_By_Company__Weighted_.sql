select

count (faultid) as [Number of Projects],
aareadesc as [Company Name],
sum(foppvalue) as [Total Project Value],
ROUND(sum(foppvalue * FOppConversionProbability*1.0/100),2)  as [Weighted Project Value]


from faults 

join area on faults.areaint = area.aarea
join requesttype on faults.requesttypenew = requesttype.rtid

where foppvalue > 0
and status not in (8,9)
and fdeleted = 0
and RTIsOpportunity = 1

group by aareadesc

/*, rtdesc, FOppConversionProbability*/
