select uusername [Username]
, uinactive as [Inactive?]
, Case when usite not in (select ssitenum from site) THEN 'User has invalid site. Move the user to a valid site.' WHEN (select sarea from site where ssitenum=usite) not in (select aarea from area) THEN 'User''s site has an invalid Customer. Move the site to a valid Customer.' ELSE '' END AS [Problem]
, (select top 1 LogoutRedirectUri from NHD_identity_application where DisplayName = 'nethelpdesk-agent-web-application')+'customer?userid='+cast(uid as nvarchar) as [Link to User]
, (select top 1 LogoutRedirectUri from NHD_identity_application where DisplayName = 'nethelpdesk-agent-web-application')+'customer?siteid='+cast(usite as nvarchar) as [Link to Site]
from users where usite not in (select ssitenum from site) or (select sarea from site where ssitenum=usite) not in (select aarea from area) and uusername not like '%General User%'
