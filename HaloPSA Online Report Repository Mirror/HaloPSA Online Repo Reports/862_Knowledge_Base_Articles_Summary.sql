select abstract as 'Summary' 	,description as 'Full Details' 	,resolution as 'Resolution' 	,datecreated as 'Date Added' 	,uname as 'Created by' from kbentry   left join uname on uname.unum = kbentry.whocreated 

