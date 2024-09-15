select 
	  dinvno as [Asset Tag]
	, (select top 1 drwhen from devicereview where did=drdid order by drwhen desc) as [Date Reviewed]
	, isnull((select top 1 case when drdetailscorrect=1 then 'Correct' when drdetailscorrect=0 then 'Incorrect' else 'Unknown' end from devicereview where did=drdid order by drwhen desc),'Unknown') as [Details Correct]
 from device
