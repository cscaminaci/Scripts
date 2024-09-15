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

FROM KBENTRY
JOIN FAQLISTDET ON faqdkbid = id
JOIN faqlisthead ON faqdid = faqid


WHERE faqlistdesc not like '%Welcome to HaloCRM%'
