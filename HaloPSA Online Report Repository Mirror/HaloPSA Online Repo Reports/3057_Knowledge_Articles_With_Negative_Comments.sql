select 
  kbvnegativecomment as [Comment],
  id as [ID],
  abstract AS [Article],
  faqlistdesc AS [FAQ]
from kbvotes
join kbentry on kbvkbid=id
JOIN FAQLISTDET ON faqdkbid = id
JOIN faqlisthead ON faqdid = faqid
where kbvnegativecomment is not null

and faqlistdesc not like '%welcome to halocrm%'
