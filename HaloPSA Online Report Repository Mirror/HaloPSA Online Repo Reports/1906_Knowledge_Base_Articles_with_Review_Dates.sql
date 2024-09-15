SELECT ID
,abstract AS [KB Article]
	,faqlistdesc AS [FAQ]

,Nextreviewdate as [Next Review Date]
,Lastreviewdate as [Last Review Date]
,(select uname from uname where unum=Reviewedby) as [Reviewed By]

FROM KBENTRY
JOIN FAQLISTDET ON faqdkbid = id
JOIN faqlisthead ON faqdid = faqid
