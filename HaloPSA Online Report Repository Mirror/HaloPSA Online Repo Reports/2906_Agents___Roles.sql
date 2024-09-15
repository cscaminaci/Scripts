select top 100 percent 
uname.unum [Agent ID],
uname.uname [Agent Name],
Name [Role Name]
from nhd_roles
join nhd_userroles on nhd_userroles.roleid=nhd_roles.id
join nhd_user on nhd_user.id=nhd_userroles.userid
join uname on username=uname
where uname.uisdisabled=0
order by uname.unum asc
