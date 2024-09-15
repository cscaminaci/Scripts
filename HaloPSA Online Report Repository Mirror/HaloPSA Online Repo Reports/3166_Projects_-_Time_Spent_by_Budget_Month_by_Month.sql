	SELECT distinct
[Project]
  ,[Project Summary]
	,[Budget]
	,[Year]
	,[Jan] 
	,[Feb] 
	,[Mar] 
	,[Apr] 
	,[May] 
	,[Jun] 
	,[Jul] 
	,[Aug]
	,[Sep] 
	,[Oct] 
	,[Nov] 
	,[Dec] 
	,[Jan]+[Feb]+[Mar]+[Apr]+[May]+[Jun]+[Jul]+[Aug]+[Sep]+[Oct]+[Nov]+[Dec] as [Total Used]
FROM(
	SELECT 
	[Project]
  , [Project Summary]
	, [Budget]
	, date_year as 'Year'
	,isnull([1], 0) AS [Jan]
    ,isnull([2], 0)  AS [Feb]
    ,isnull([3], 0) AS [Mar]
    ,isnull([4], 0) AS [Apr]
    ,isnull([5], 0) AS [May]
    ,isnull([6], 0) AS [Jun]
    ,isnull([7], 0) AS [Jul]
    ,isnull([8], 0) AS [Aug]
    ,isnull([9], 0) AS [Sep]
    ,isnull([10], 0)  AS [Oct]
    ,isnull([11], 0)  AS [Nov]
    ,isnull([12], 0)  AS [Dec]
FROM(
select distinct
/*[Ticket]
, [Parent]*/
[Project]
, [Project Summary]
, [Budget]
, round(sum(timetaken), 2) [Time]
, date_year
, date_month
 from
(select distinct
  f.faultid [Ticket]
, f.fxrefto [Parent]
, case
  when f.fxrefto in (select faultid from faults where fxrefto > 0) then (select fxrefto from faults where faultid=f.fxrefto)
  when  f.fxrefto > 0 then f.fxrefto
  else f.faultid end [Project]
, case
  when f.fxrefto in (select faultid from faults where fxrefto > 0) then concat((select fxrefto from faults where faultid=f.fxrefto), ' - ' ,(select (SELECT symptom FROM faults WHERE faultid =g.fxrefto) from faults g where g.faultid=f.fxrefto))
  when  f.fxrefto > 0 then concat(f.fxrefto, ' - ', (SELECT symptom FROM faults WHERE f.fxrefto =faultid))
  else concat(f.faultid, ' - ', f.symptom) end [Project Summary]
, (SELECT btname FROM budgettype WHERE btid = f.fbudgettype) as [Budget]
, uname
, timetaken
, whe_
, date_year
, date_month

from faults f
join actions a on a.faultid=f.faultid
join uname on unum=whoagentid 
JOIN calendar ON date_year = datepart(year, whe_) AND date_month = datepart(month, whe_)
WHERE f.FDeleted = f.FMergedIntoFaultid
AND whe_ BETWEEN @startdate and @enddate
AND requesttypenew IN (SELECT rtid FROM requesttype WHERE rtisproject =1)
)a
group by /*[Ticket], [Parent],*/ [Budget], [Project], date_year, date_month, [Project Summary]
)m
pivot(max([Time]) FOR date_month IN (
                     [1]
                     ,[2]
                     ,[3]
                     ,[4]
                     ,[5]
                     ,[6]
                     ,[7]
                     ,[8]
                     ,[9]
                     ,[10]
                     ,[11]
                     ,[12]
                )) pvr
			)joe



