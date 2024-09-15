SELECT
	  uusername as 'User'
	, sdesc as 'Site'
	, aareadesc as 'Customer'
	, uemail as 'Email'
	, CASE WHEN Uviewscope = 3 THEN N'No Access'
		   WHEN Uviewscope = 0 THEN 'This Users Tickets'
		   WHEN Uviewscope = 1 THEN 'Site Tickets'
		   WHEN Uviewscope = 2 THEN 'Clients Tickets'
		   WHEN Uviewscope = 4 THEN 'Top Level Tickets, assets and invoices'
		   WHEN Uviewscope = 5 THEN 'Department Tickets'
		   WHEN Uviewscope = 9 THEN 'Site Contact Tickets'
		   WHEN Uviewscope = 10 THEN 'All Tickets'
		   else 'Not set'
	  END AS 'Web Access Level'

	  	, CASE WHEN udevicescope = 3 THEN N'No Access'
		   WHEN udevicescope = 0 THEN 'This Users Assets'
		   WHEN udevicescope = 1 THEN 'Site Assets'
		   WHEN udevicescope = 2 THEN 'Clients Assets'
		   WHEN udevicescope = 4 THEN 'Top Level Assets'
		   WHEN udevicescope = 5 THEN 'Department Assets'
		   WHEN udevicescope = 9 THEN 'Site Contact Assets'
		   WHEN udevicescope = 10 THEN 'All Assets'
		else 'Not set'
	  END AS 'Asset Access Level'

	  
	  , CASE WHEN Uinactive = 'False' THEN 'Active'
           WHEN Uinactive = 'True' THEN 'Inactive'
           END AS 'Status'
      , ucanadd as [Can add new tickets]
      , uischangeapprover as [Can partake in approvals]
        , CASE WHEN ucataloglevel = 0 THEN '1'
           WHEN ucataloglevel = 1 THEN '2'
           WHEN ucataloglevel = 2 THEN '3'
      END AS 'Service Catalog Level'
      , uisimportantcontact as [Is an important contact?]
      , ulastlogindate as [Last login date]

FROM users
JOIN site on usite = Ssitenum
JOIN area on aarea = sarea
