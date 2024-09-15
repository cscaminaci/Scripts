SELECT
	  uname as [Agent]
	, USsection as [Section]
	, count(CASE WHEN status<>9 THEN Faultid END) as [Total Open]
	, count(CASE WHEN convert(date,dateoccured) like convert(date, getdate()) THEN faultid END) as [Opened Today]
	, count(CASE WHEN convert(date,datecleared) like convert(date, getdate()) and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END) as [Opened and Closed Today]
	, CASE 
		WHEN DATEPART(dw,getdate())=1
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend1) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=2
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend2) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=3
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend3) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=4
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend4) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=5
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend5) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=6
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend6) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
		WHEN DATEPART(dw,getdate())=7
		THEN count(CASE WHEN convert(time,dateoccured)<convert(time,Wend7) and Status<>9 and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)
	  END as [Open At COB]
	, CASE WHEN 
	  (count(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)=0)
	  THEN 0
	  ELSE
	  (count(CASE WHEN convert(date,datecleared) like convert(date, getdate()) and convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)*100/(count(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN faultid END)))
      END as [Close Rate for Today (%)]
	, ROUND(ISNULL(AVG(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN FResponseTime END),0),2) as [Average Response Time]
	, (select replace(cast(convert(decimal(10,2),cast((isnull(ROUND(ISNULL(AVG(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN FResponseTime END),0),2),0)) as int)+((((isnull(ROUND(ISNULL(AVG(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN FResponseTime END),0),2),0) -cast((isnull
	(ROUND(ISNULL(AVG(CASE WHEN convert(date, dateoccured) like convert(date, getdate()) THEN FResponseTime END),0),2),0)) as int))*.60)))) as varchar),'.',':')) as [Average Response Time (HHMM)]
FROM Faults
JOIN uname on unum=Assignedtoint
JOIN UnameSection on USunum=Assignedtoint 
LEFT JOIN workdays on UWorkDayID=Wdid 
WHERE USinsection=1  and fdeleted=0

GROUP BY uname, USsection




