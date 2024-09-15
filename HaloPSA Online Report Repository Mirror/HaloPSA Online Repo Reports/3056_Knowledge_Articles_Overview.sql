SELECT abstract AS [KB Article]
	,faqlistdesc AS [FAQ]
	,(
		SELECT count(*)
		FROM attachment
		WHERE attype = 11
			AND atuniqueid = id
		) AS [No. Attachments]
	,ViewedCount AS [View Count]
	,KBuseful AS [Up Vote]
	,KBnotuseful AS [Down vote]
        ,uName AS [Author]
       

FROM KBENTRY
JOIN FAQLISTDET ON faqdkbid = id
JOIN faqlisthead ON faqdid = faqid
left join uname on uname.unum = kbentry.whocreated 


where faqlistdesc not like '%welcome to halocrm%'
