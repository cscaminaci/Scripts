SELECT
	  (select uname from uname where assignedtoint=unum) as [Assigned]
	, symptom as [Summary]
	, CASE WHEN LEN(foppcompanyname)>0 THEN foppcompanyname ELSE (select aareadesc from area where aarea=areaint) END as [Business]
        , (select fvalue from lookup where fid=57 and fcode=foppclosurecategory) as [Closure Category]
	, datecleared as [Date Closed]
	, datename(mm,datecleared) as [Month Closed]
	, datepart(yyyy,datecleared) as [Year Closed]
	, foppvalue as [Value]
	, foppconversionprobability as [Conversion Probability]
FROM faults
WHERE requesttypenew in (select rtid from requesttype where rtisopportunity=1)
	AND fdeleted = 0
	AND fmergedintofaultid=0
	AND datecleared > @startdate and datecleared < @enddate
