SELECT
UserName AS [Agent Name],
UName.UNum AS [Agent ID],
NHD_Roles.Name AS [Role Name],
UJobTitle AS [Job Title]

from nhd_roles
join nhd_userroles on nhd_userroles.roleid=nhd_roles.id
join nhd_user on nhd_user.id=nhd_userroles.userid
JOIN NHD_UserClaims ON NHD_UserClaims.UserID = nhd_user.ID
left join nhd_roleclaims on nhd_roleclaims.roleid = nhd_userroles.RoleId
JOIN UName ON UName = UserName

WHERE (nhd_userclaims.ClaimType = 'SA'
AND nhd_userclaims.ClaimValue = 'true') or
(nhd_roleclaims.ClaimType = 'SA'
AND nhd_roleclaims.ClaimValue = 'true')

group by UserName, UName.UNum, NHD_Roles.Name, UJobTitle
