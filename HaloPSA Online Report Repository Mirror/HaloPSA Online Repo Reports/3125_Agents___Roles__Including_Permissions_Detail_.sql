SELECT * FROM (

SELECT *, ROW_NUMBER() OVER( PARTITION BY pvt.[Role] ORDER BY pvt.[Role] ASC) AS r FROM (

SELECT
	a.[Role],
	a.[Permission Name],
	a.[Permission Value],
	STRING_AGG(a.uname, ', ') AS [Agent(s) With This Role]
FROM (

SELECT
    Name as [Role],
    CASE
        WHEN [ClaimType] like 'SA' then 'Is a Halo Administrator'
		when [ClaimType] like 'l0' then 'Editing of own Preferences'
		when [ClaimType] like 'ln' then 'Editing of Own Notifications'
		
		when [ClaimType] like 'Tx' then 'Tickets Access Level' 
		when [ClaimType] like 'Ux' then 'Clients Access Level'
		when [ClaimType] like 'Fx' then 'Users Access Level'
		when [ClaimType] like 'Ex' then 'CRM Access Level'
		when [ClaimType] like 'Dx' then 'Assets Access Level'
		when [ClaimType] like 'Ax' then 'Calendars and Appointments Access level'
		when [ClaimType] like 'Bx' then 'Knowledge Base Access Level'
		when [ClaimType] like 'Sx' then 'Suppliers Access Level'
		when [ClaimType] like 'Ix' then 'Items Access Level'
		when [ClaimType] like 'Ox' then 'Sales Access Level'
		when [ClaimType] like 'Qx' then 'Quotations Access Level'
		when [ClaimType] like 'Yx' then 'Sales Orders Access Level'
		when [ClaimType] like 'Zx' then 'Purchase Orders Access Level'
		when [ClaimType] like 'Jx' then 'Billing Details Access Level'
		when [ClaimType] like 'Xx' then 'Invoices Access Level'
		when [ClaimType] like 'Rx' then 'Reporting Access Level'
		when [ClaimType] like 'Cx' then 'Client Contracts Access Level'
		when [ClaimType] like 'Gx' then 'Supplier Contracts Access Level'
		when [ClaimType] like 'Vx' then 'Services Access Level'
		when [ClaimType] like 'Wx' then 'Software Releases Access Level'
		when [ClaimType] like 'Hx' then 'Timesheets Access Level'
		when [ClaimType] like 'Lx' then 'Software Licencing Access Level'

		when [ClaimType] like 'Kx' then 'Distribution Lists Access Level'
		when [ClaimType] like 'Mx' then 'Document Management Access Level'
		when [ClaimType] like 'Nx' then 'Mail Campaign Access Level'

		when [ClaimType] like 'l6' then 'Can add new Tickets'
		when [ClaimType] like 'lf' then 'Can Edit Closed Tickets'
		when [ClaimType] like 'l9' then 'Can View Unassigned Tickets'
		when [ClaimType] like 'l8' then 'Can view Tickets that are assigned to other Agents'
		when [ClaimType] like 'lc' then 'Can change a Tickets Ticket Type'
		when [ClaimType] like 'l7' then 'Can Re-Assign Tickets'
		when [ClaimType] like 'l1' then 'Can Edit Advanced Ticket Details'
		when [ClaimType] like 'l5' then 'Editing of Actions'
		when [ClaimType] like 'l4' then 'Can Remove Tickets'
		when [ClaimType] like 'ld' then 'Can assign to Agents in Teams the Agent is not a member of'
		when [ClaimType] like 'le' then 'Can Edit Tickets Which Are Not Assigned To Them'
		when [ClaimType] like 'lj' then 'Can override maximum priority escalation at ticket type level'
		when [ClaimType] like 'lh' then 'Can Override Ticket Review Processing'
		when [ClaimType] like 'll' then 'Can Use the Treat as Spam button'
		when [ClaimType] like 'lm' then 'Can Export Tickets'
		when [ClaimType] like 'lo' then 'Can always change Ticket Statuses and re-assign Tickets outside of actions'
		when [ClaimType] like 'Td' then 'Can remove To-Do items'

		when [ClaimType] like 'lb' then 'Editing of Appointments'
		when [ClaimType] like 'lg' then 'Adding New Appointments'
		when [ClaimType] like 'lz' then 'Visibility of Appointments'
		when [ClaimType] like 'lr' then 'Deleting of Appointments'

		when [ClaimType] like 'Ft' then 'Allow use of all Ticket Types'
		when [ClaimType] like 'Fc' then 'Allow use of all Clients'
		when [ClaimType] like 'Ff' then 'Allow use of all Asset Fields'

		when [ClaimType] like 'l3' then 'My Approvals Page Access'
		when [ClaimType] like 'l2' then 'Can Override Approval Results'

		when [ClaimType] like 'li' then 'Can view item costs'
		when [ClaimType] like 'pi' then 'Can View Item Prices'
		when [ClaimType] like 'A1' then 'Can View Agent Costs'

		when [ClaimType] like 'At' then 'Allow creation of new Ticket Types and linked objects'
		when [ClaimType] like 'As' then 'Allow creation of new Scheduled Tickets'
		when [ClaimType] like 'lt' then 'Allow creation of new global templates'
		/*when [ClaimType] like 'lx' then 'Can Create Canned Text'*/
		when [ClaimType] like 'ly' then 'Can Create Dashboards'
		when [ClaimType] like 'Ad' then 'Can Create SQL Data Sources'
		when [ClaimType] like 'ls' then 'Can Create Custom Fields'
		when [ClaimType] like 'Af' then 'Can Create Field Groups'
		when [ClaimType] like 'mg' then 'Can Create Message Groups'
		when [ClaimType] like 'Ar' then 'Can Create Ticket Rules'
		when [ClaimType] like 'Av' then 'Can Create Roles'
		when [ClaimType] like 'Az' then 'Can Create SLAs'
		when [ClaimType] like 'Al' then 'Can Create Languages'
		when [ClaimType] like 'Aq' then 'Can Create Quote Group Templates'
		when [ClaimType] like 'Cp' then 'Can Create Chat Profiles'
		when [ClaimType] like 'Fl' then 'Can Create FAQ Lists'

		when [ClaimType] like 'la' then 'Password Fields'
		when [ClaimType] like 'lk' then 'Can change whether Suppliers/Clients/Sites/Users are active or inactive'
		when [ClaimType] like 'Ru' then 'Can Publish Reports'



when [ClaimType] like 'Px' then 'Project Level'
when [ClaimType] like 'LC' then 'Chat Level'
when [ClaimType] like 'PR' then 'PR'
when [ClaimType] like 'A' then 'Technician'

when [ClaimType] like 'D1' then 'Can View Site Docs'
when [ClaimType] like 'lu' then 'Can view PowerShell results and requeue scripts on Tickets'
when [ClaimType] like 'lv' then 'Can queue PowerShell scripts via a quick action'
when [ClaimType] like 'Fa' then 'Allow use of all Asset Types'

else [ClaimType]
    END AS [Permission Name],

case 

when [ClaimType] like 'Kx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Send'
			when ClaimValue like '3' then 'Read and Modify'
			end
when [ClaimType] like 'ly' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Af' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'mg' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Ar' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Av' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Az' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Al' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Aq' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Cp' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Fl' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Ru' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'ls' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'lo' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'lh' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'TD' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimType] like 'Mx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimType] like 'Nx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimType] like 'lz' then case 
			when ClaimValue like '0' then 'Can View Own Appointments Only'
			when ClaimValue like '1' then 'Can View Team Appointments Only'
			when ClaimValue like '2' then 'Can View Team and Department Appointments Only'
			when ClaimValue like '3' then 'Can View All Appointments'
			end 
when [ClaimType] like 'Jx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 


when [ClaimType] like 'pi' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimType] like 'A1' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end 


when [ClaimType] like 'lg' then case 
			when ClaimValue like '0' then 'Cannot Add Appointments'
			when ClaimValue like '1' then 'Can Add Own Appointments Only'
			when ClaimValue like '2' then 'Can Add All Appointments'
			end 		
when [ClaimType] like 'ln' then case 
			when ClaimValue like 'false' then 'Cannot Edit Notifications'
			when ClaimValue like 'true' then 'Can Edit Notifications'
			end 		
when [ClaimType] like 'SA' then case 
			when ClaimValue like 'false' then 'No'
			when ClaimValue like 'true' then 'Yes'
			end 
when [ClaimType] like 'l0' then case 
			when ClaimValue like 'false' then 'Cannot Edit own Preferences'
			when ClaimValue like 'true' then 'Can Edit own Preferences'
			end 
when [ClaimType] like 'Zx' or [ClaimType] like 'Yx' or [ClaimType] like 'Qx' or [ClaimType] like 'Sx' or [ClaimType] like 'Vx' or [ClaimType] like 'Wx' or [ClaimType] like 'Cx' or [ClaimType] like 'Bx' or [ClaimType] like 'Px' or [ClaimType] like 'Ox' or [ClaimType] like 'Rx' or [ClaimType] like 'Ax' or [ClaimType] like 'Ex' or [ClaimType] like 'Gx' or [ClaimType] like 'Tx' or [ClaimType] like 'Lx' then case
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
When [ClaimType] like 'Fx' or [ClaimType] like 'Ux' or [ClaimType] like 'Ix' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'View (Names Only)'
			when ClaimValue like '2' then 'Read Only'
			when ClaimValue like '3' then 'Read and Modify'
			end 
When [ClaimType] like 'Dx' or [ClaimType] like 'Xx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			when ClaimValue like '3' then 'Read, Modify and Remove'
			end
When [ClaimType] like 'Hx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read and Modify (Own)'
			when ClaimValue like '2' then 'Read and Modify (Managed)'
			when ClaimValue like '3' then 'Read Only'
			when ClaimValue like '4' then 'Read and Modify (All)'
			end			
when [ClaimType] like 'l4' or [ClaimType] like 'l6' or [ClaimType] like 'l9' or [ClaimType] like 'l8' or [ClaimType] like 'lc' or [ClaimType] like 'l7' or [ClaimType] like 'l1' or [ClaimType] like 'l2' or [ClaimType] like 'lv' or [ClaimType] like 'As' or [ClaimType] like 'Ft' or [ClaimType] like 'Fc' or [ClaimType] like 'Ff' or [ClaimType] like 'Fa' or [ClaimType] like 'Ad' or [ClaimType] like 'lt' or [ClaimType] like 'lm' or [ClaimType] like 'li' or [ClaimType] like 'll' or [ClaimType] like 'ld' or [ClaimType] like 'lf' or [ClaimType] like 'le' or [ClaimType] like 'lj' or [ClaimType] like 'lk' or [ClaimType] like 'At' or [ClaimType] like 'lu' then case
			when ClaimValue like '1' then 'Yes'
			when ClaimValue like '0' then 'No'
			end
When [ClaimType] like 'l5' then case
			when ClaimValue like '0' then 'Cannot Edit Actions'
			when ClaimValue like '1' then 'Can Edit Own Actions Only'
			when ClaimValue like '3' then 'Can Edit All Actions'
			end
When [ClaimType] like 'lb' then case
			when ClaimValue like '0' then 'Cannot Edit Appointments'
			when ClaimValue like '1' then 'Can Edit Own Appointments Only'
			when ClaimValue like '3' then 'Can Edit All Appointments'
			end
When [ClaimType] like 'l3' then case
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Can Access'
			end 
when [ClaimType] like 'la' then case
			when ClaimValue like '0' then 'Not Visible'
			when ClaimValue like '1' then 'Visible'
			end 
when [ClaimType] like 'lr' then case
			when ClaimValue like '0' then 'Cannot Remove Appointments'
			when ClaimValue like '1' then 'Can Remove Own Appointments Only'
		    when ClaimValue like '3' then 'Can Remove All Appointments'
			end 
else ClaimValue
end as [Permission Value],
    uname
FROM NHD_Roles

LEFT JOIN NHD_RoleClaims ON NHD_Roles.Id = RoleId
LEFT JOIN NHD_UserRoles ON NHD_Roles.Id = NHD_UserRoles.RoleId
LEFT JOIN NHD_User ON UserId = NHD_User.ID
LEFT JOIN uname ON NHD_User.unum = uname.unum and Uisdisabled='False'

/*WHERE Name = 'Finance Admin'*/

) a 

GROUP BY
	a.[Role],
	a.[Permission Name],
	a.[Permission Value]

) src 

PIVOT(
	MAX(src.[Permission Value]) 
	FOR src.[Permission Name] IN (
		[Is a Halo Administrator],
		[Editing of own Preferences],
		[Editing of Own Notifications],
		[Tickets Access Level],
		[Clients Access Level],
		[Users Access Level],
		[CRM Access Level],
		[Assets Access Level],
		[Calendars and Appointments Access level],
		[Knowledge Base Access Level],
		[Suppliers Access Level],
		[Items Access Level],
		[Sales Access Level],
		[Quotations Access Level],
		[Sales Orders Access Level],
		[Purchase Orders Access Level],
		[Billing Details Access Level],
		[Invoices Access Level],
		[Reporting Access Level],
		[Client Contracts Access Level],
		[Supplier Contracts Access Level],
		[Services Access Level],
		[Software Releases Access Level],
		[Timesheets Access Level],
		[Software Licencing Access Level],
		[Distribution Lists Access Level],
		[Document Management Access Level],
		[Mail Campaign Access Level],

[Can add new Tickets],
[Can Edit Closed Tickets],
[Can View Unassigned Tickets],
[Can view Tickets that are assigned to other Agents],
[Can change a Tickets Ticket Type],
[Can Re-Assign Tickets],
[Can Edit Advanced Ticket Details],
[Editing of Actions],
[Can Remove Tickets],
[Can assign to Agents in Teams the Agent is not a member of],
[Can Edit Tickets Which Are Not Assigned To Them],
[Can override maximum priority escalation at ticket type level],
[Can Override Ticket Review Processing],
[Can Use the Treat as Spam button],
[Can Export Tickets],
[Can always change Ticket Statuses and re-assign Tickets outside of actions],
[Can remove To-Do items],

[Editing of Appointments],
[Adding New Appointments],
[Visibility of Appointments],
[Deleting of Appointments],

[Allow use of all Ticket Types],
[Allow use of all Clients],
[Allow use of all Asset Fields],

[My Approvals Page Access],
[Can Override Approval Results],

[Can view item costs],
[Can View Item Prices],
[Can View Agent Costs],

[Allow creation of new Ticket Types and linked objects],
[Allow creation of new Scheduled Tickets],
[Allow creation of new global templates],
[Can Create Dashboards],
[Can Create SQL Data Sources],
[Can Create Custom Fields],
[Can Create Field Groups],
[Can Create Message Groups],
[Can Create Ticket Rules],
[Can Create Roles],
[Can Create SLAs],
[Can Create Languages],
[Can Create Quote Group Templates],
[Can Create Chat Profiles],
[Can Create FAQ Lists],

[Password Fields],
[Can change whether Suppliers/Clients/Sites/Users are active or inactive],
[Can Publish Reports]

/*[Project Level],
[Chat Level],
[PR],
[Technician],
[Can View Site Docs],
[Can view PowerShell results and requeue scripts on Tickets]*/
			
		)
) pvt

) fin 

WHERE fin.r = 1
