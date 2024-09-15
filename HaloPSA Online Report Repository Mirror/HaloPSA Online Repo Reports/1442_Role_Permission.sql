
select [Role] 
,case when [ClaimTypeStandardised] like 'SA' then 'Administrator'
when [ClaimTypeStandardised] like 'A' then 'Technician'
when [ClaimTypeStandardised] like 'Tx' then 'Ticket Level' 
when [ClaimTypeStandardised] like 'Ax' then 'Calendar'
when [ClaimTypeStandardised] like 'Ux' then 'Customer Level'
when [ClaimTypeStandardised] like 'Sx' then 'Supplier Level'
when [ClaimTypeStandardised] like 'Ix' then 'Item Level'
when [ClaimTypeStandardised] like 'Vx' then 'Service Level'
when [ClaimTypeStandardised] like 'Cx' then 'Contract Level'
when [ClaimTypeStandardised] like 'Px' then 'Project Level'
when [ClaimTypeStandardised] like 'Ox' then 'Sales Level'
when [ClaimTypeStandardised] like 'Rx' then 'Reporting Level'
when [ClaimTypeStandardised] like 'Wx' then 'Software Level'
when [ClaimTypeStandardised] like 'Bx' then 'Knowledge Base Level'
when [ClaimTypeStandardised] like 'Dx' then 'Asset Level'
when [ClaimTypeStandardised] like 'Hx' then 'Time Sheet Level'

when [ClaimTypeStandardised] like 'LC' then 'Chat Level'
when [ClaimTypeStandardised] like 'PR' then 'PR'

when [ClaimTypeStandardised] like 'l1' then 'Advanced Edit'
when [ClaimTypeStandardised] like 'l2' then 'Approvals Override'
when [ClaimTypeStandardised] like 'l3' then 'Approvals Page Access'
when [ClaimTypeStandardised] like 'l4' then 'Can Remove Tickets'
when [ClaimTypeStandardised] like 'l5' then 'Can Edit Actions'
when [ClaimTypeStandardised] like 'l6' then 'Can Log Tickets'
when [ClaimTypeStandardised] like 'l7' then 'Can Re-Assign Tickets'
when [ClaimTypeStandardised] like 'l8' then 'Can View Tech Tickets'
when [ClaimTypeStandardised] like 'l9' then 'Can View Unassigned Tickets'
when [ClaimTypeStandardised] like 'l0' then 'Can Edit Preferences'
when [ClaimTypeStandardised] like 'la' then 'Password Level'
when [ClaimTypeStandardised] like 'lb' then 'Can Edit Appointments'
when [ClaimTypeStandardised] like 'lc' then 'Can Change Ticket Type'
when [ClaimTypeStandardised] like 'D1' then 'Can View Site Docs'
WHEN [ClaimTypeStandardised] like 'SA' then 'Is a Halo Administrator'
		when [ClaimTypeStandardised] like 'l0' then 'Editing of own Preferences'
		when [ClaimTypeStandardised] like 'ln' then 'Editing of Own Notifications'
		
		when [ClaimTypeStandardised] like 'Tx' then 'Tickets Access Level' 
		when [ClaimTypeStandardised] like 'Ux' then 'Clients Access Level'
		when [ClaimTypeStandardised] like 'Fx' then 'Users Access Level'
		when [ClaimTypeStandardised] like 'Ex' then 'CRM Access Level'
		when [ClaimTypeStandardised] like 'Dx' then 'Assets Access Level'
		when [ClaimTypeStandardised] like 'Ax' then 'Calendars and Appointments Access level'
		when [ClaimTypeStandardised] like 'Bx' then 'Knowledge Base Access Level'
		when [ClaimTypeStandardised] like 'Sx' then 'Suppliers Access Level'
		when [ClaimTypeStandardised] like 'Ix' then 'Items Access Level'
		when [ClaimTypeStandardised] like 'Ox' then 'Sales Access Level'
		when [ClaimTypeStandardised] like 'Qx' then 'Quotations Access Level'
		when [ClaimTypeStandardised] like 'Yx' then 'Sales Orders Access Level'
		when [ClaimTypeStandardised] like 'Zx' then 'Purchase Orders Access Level'
		when [ClaimTypeStandardised] like 'Jx' then 'Billing Details Access Level'
		when [ClaimTypeStandardised] like 'Xx' then 'Invoices Access Level'
		when [ClaimTypeStandardised] like 'Rx' then 'Reporting Access Level'
		when [ClaimTypeStandardised] like 'Cx' then 'Client Contracts Access Level'
		when [ClaimTypeStandardised] like 'Gx' then 'Supplier Contracts Access Level'
		when [ClaimTypeStandardised] like 'Vx' then 'Services Access Level'
		when [ClaimTypeStandardised] like 'Wx' then 'Software Releases Access Level'
		when [ClaimTypeStandardised] like 'Hx' then 'Timesheets Access Level'
		when [ClaimTypeStandardised] like 'Lx' then 'Software Licencing Access Level'

		when [ClaimTypeStandardised] like 'Kx' then 'Distribution Lists Access Level'
		when [ClaimTypeStandardised] like 'Mx' then 'Document Management Access Level'
		when [ClaimTypeStandardised] like 'Nx' then 'Mail Campaign Access Level'

		when [ClaimTypeStandardised] like 'l6' then 'Can add new Tickets'
		when [ClaimTypeStandardised] like 'lf' then 'Can Edit Closed Tickets'
		when [ClaimTypeStandardised] like 'l9' then 'Can View Unassigned Tickets'
		when [ClaimTypeStandardised] like 'l8' then 'Can view Tickets that are assigned to other Agents'
		when [ClaimTypeStandardised] like 'lc' then 'Can change a Tickets Ticket Type'
		when [ClaimTypeStandardised] like 'l7' then 'Can Re-Assign Tickets'
		when [ClaimTypeStandardised] like 'l1' then 'Can Edit Advanced Ticket Details'
		when [ClaimTypeStandardised] like 'l5' then 'Editing of Actions'
		when [ClaimTypeStandardised] like 'l4' then 'Can Remove Tickets'
		when [ClaimTypeStandardised] like 'ld' then 'Can assign to Agents in Teams the Agent is not a member of'
		when [ClaimTypeStandardised] like 'le' then 'Can Edit Tickets Which Are Not Assigned To Them'
		when [ClaimTypeStandardised] like 'lj' then 'Can override maximum priority escalation at ticket type level'
		when [ClaimTypeStandardised] like 'lh' then 'Can Override Ticket Review Processing'
		when [ClaimTypeStandardised] like 'll' then 'Can Use the Treat as Spam button'
		when [ClaimTypeStandardised] like 'lm' then 'Can Export Tickets'
		when [ClaimTypeStandardised] like 'lo' then 'Can always change Ticket Statuses and re-assign Tickets outside of actions'
		when [ClaimTypeStandardised] like 'Td' then 'Can remove To-Do items'

		when [ClaimTypeStandardised] like 'lb' then 'Editing of Appointments'
		when [ClaimTypeStandardised] like 'lg' then 'Adding New Appointments'
		when [ClaimTypeStandardised] like 'lz' then 'Visibility of Appointments'
		when [ClaimTypeStandardised] like 'lr' then 'Deleting of Appointments'

		when [ClaimTypeStandardised] like 'Ft' then 'Allow use of all Ticket Types'
		when [ClaimTypeStandardised] like 'Fc' then 'Allow use of all Clients'
		when [ClaimTypeStandardised] like 'Ff' then 'Allow use of all Asset Fields'

		when [ClaimTypeStandardised] like 'l3' then 'My Approvals Page Access'
		when [ClaimTypeStandardised] like 'l2' then 'Can Override Approval Results'

		when [ClaimTypeStandardised] like 'li' then 'Can view item costs'
		when [ClaimTypeStandardised] like 'pi' then 'Can View Item Prices'
		when [ClaimTypeStandardised] like 'A1' then 'Can View Agent Costs'

		when [ClaimTypeStandardised] like 'At' then 'Allow creation of new Ticket Types and linked objects'
		when [ClaimTypeStandardised] like 'As' then 'Allow creation of new Scheduled Tickets'
		when [ClaimTypeStandardised] like 'lt' then 'Allow creation of new global templates'
		/*when [ClaimTypeStandardised] like 'lx' then 'Can Create Canned Text'*/
		when [ClaimTypeStandardised] like 'ly' then 'Can Create Dashboards'
		when [ClaimTypeStandardised] like 'Ad' then 'Can Create SQL Data Sources'
		when [ClaimTypeStandardised] like 'ls' then 'Can Create Custom Fields'
		when [ClaimTypeStandardised] like 'Af' then 'Can Create Field Groups'
		when [ClaimTypeStandardised] like 'mg' then 'Can Create Message Groups'
		when [ClaimTypeStandardised] like 'Ar' then 'Can Create Ticket Rules'
		when [ClaimTypeStandardised] like 'Av' then 'Can Create Roles'
		when [ClaimTypeStandardised] like 'Az' then 'Can Create SLAs'
		when [ClaimTypeStandardised] like 'Al' then 'Can Create Languages'
		when [ClaimTypeStandardised] like 'Aq' then 'Can Create Quote Group Templates'
		when [ClaimTypeStandardised] like 'Cp' then 'Can Create Chat Profiles'
		when [ClaimTypeStandardised] like 'Fl' then 'Can Create FAQ Lists'

		when [ClaimTypeStandardised] like 'la' then 'Password Fields'
		when [ClaimTypeStandardised] like 'lk' then 'Can change whether Suppliers/Clients/Sites/Users are active or inactive'
		when [ClaimTypeStandardised] like 'Ru' then 'Can Publish Reports'
		when [ClaimTypeStandardised] like 'Px' then 'Project Level'
when [ClaimTypeStandardised] like 'LC' then 'Chat Level'
when [ClaimTypeStandardised] like 'PR' then 'PR'
when [ClaimTypeStandardised] like 'A' then 'Technician'

when [ClaimTypeStandardised] like 'D1' then 'Can View Site Docs'
when [ClaimTypeStandardised] like 'lu' then 'Can view PowerShell results and requeue scripts on Tickets'
when [ClaimTypeStandardised] like 'lv' then 'Can queue PowerShell scripts via a quick action'
when [ClaimTypeStandardised] like 'Fa' then 'Allow use of all Asset Types'
else [ClaimTypeStandardised]
end as [Permission Name]


,case When ClaimValue like 'true' then 'True'
when ClaimValue like 'false' then 'False'

when [ClaimTypeStandardised] like '%x' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimTypeStandardised] like 'l4' or [ClaimTypeStandardised] like 'l6' or [ClaimTypeStandardised] like 'l9' or [ClaimTypeStandardised] like 'l8' or [ClaimTypeStandardised] like 'lc' or [ClaimTypeStandardised] like 'l7' or [ClaimTypeStandardised] like 'l1' or [ClaimTypeStandardised] like 'l2' then case
			when ClaimValue like '1' then 'Yes'
			when ClaimValue like '0' then 'No'
			end
When [ClaimTypeStandardised] like 'l5' then case
			when ClaimValue like '0' then 'Cannot Edit Actions'
			when ClaimValue like '1' then 'Can Edit Own Actions Only'
			when ClaimValue like '3' then 'Can Edit All Actions'
			end
When [ClaimTypeStandardised] like 'lb' then case
			when ClaimValue like '0' then 'Cannot Edit Appointments'
			when ClaimValue like '1' then 'Can Edit Own Appointments Only'
			when ClaimValue like '3' then 'Can Edit All Appointments'
			end
When [ClaimTypeStandardised] like 'l3' then case
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Can Access'
			end
when [ClaimTypeStandardised] like 'l0' then case
			when ClaimValue like '0' then 'Cannot Edit Preferences'
			when ClaimValue like '1' then 'Can edit Preferences'
			end 
when [ClaimTypeStandardised] like 'la' then case
			when ClaimValue like '0' then 'Not Visible'
			when ClaimValue like '1' then 'Visible'
			end 
when [ClaimTypeStandardised] like 'Kx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Send'
			when ClaimValue like '3' then 'Read and Modify'
			end
when [ClaimTypeStandardised] like 'ly' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Af' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'mg' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Ar' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Av' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Az' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Al' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Aq' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Cp' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Fl' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Ru' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'ls' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'lo' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'lh' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'TD' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end
when [ClaimTypeStandardised] like 'Mx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimTypeStandardised] like 'Nx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimTypeStandardised] like 'lz' then case 
			when ClaimValue like '0' then 'Can View Own Appointments Only'
			when ClaimValue like '1' then 'Can View Team Appointments Only'
			when ClaimValue like '2' then 'Can View Team and Department Appointments Only'
			when ClaimValue like '3' then 'Can View All Appointments'
			end 
when [ClaimTypeStandardised] like 'Jx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 


when [ClaimTypeStandardised] like 'pi' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
when [ClaimTypeStandardised] like 'A1' then case 
			when ClaimValue like '0' then 'No'
			when ClaimValue like '1' then 'Yes'
			end 


when [ClaimTypeStandardised] like 'lg' then case 
			when ClaimValue like '0' then 'Cannot Add Appointments'
			when ClaimValue like '1' then 'Can Add Own Appointments Only'
			when ClaimValue like '2' then 'Can Add All Appointments'
			end 		
when [ClaimTypeStandardised] like 'ln' then case 
			when ClaimValue like 'false' then 'Cannot Edit Notifications'
			when ClaimValue like 'true' then 'Can Edit Notifications'
			end 		
when [ClaimTypeStandardised] like 'SA' then case 
			when ClaimValue like 'false' then 'No'
			when ClaimValue like 'true' then 'Yes'
			end 
when [ClaimTypeStandardised] like 'l0' then case 
			when ClaimValue like 'false' then 'Cannot Edit own Preferences'
			when ClaimValue like 'true' then 'Can Edit own Preferences'
			end 
when [ClaimTypeStandardised] like 'Zx' or [ClaimTypeStandardised] like 'Yx' or [ClaimTypeStandardised] like 'Qx' or [ClaimTypeStandardised] like 'Sx' or [ClaimTypeStandardised] like 'Vx' or [ClaimTypeStandardised] like 'Wx' or [ClaimTypeStandardised] like 'Cx' or [ClaimTypeStandardised] like 'Bx' or [ClaimTypeStandardised] like 'Px' or [ClaimTypeStandardised] like 'Ox' or [ClaimTypeStandardised] like 'Rx' or [ClaimTypeStandardised] like 'Ax' or [ClaimTypeStandardised] like 'Ex' or [ClaimTypeStandardised] like 'Gx' or [ClaimTypeStandardised] like 'Tx' or [ClaimTypeStandardised] like 'Lx' then case
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			end 
When [ClaimTypeStandardised] like 'Fx' or [ClaimTypeStandardised] like 'Ux' or [ClaimTypeStandardised] like 'Ix' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'View (Names Only)'
			when ClaimValue like '2' then 'Read Only'
			when ClaimValue like '3' then 'Read and Modify'
			end 
When [ClaimTypeStandardised] like 'Dx' or [ClaimTypeStandardised] like 'Xx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read Only'
			when ClaimValue like '2' then 'Read and Modify'
			when ClaimValue like '3' then 'Read, Modify and Remove'
			end
When [ClaimTypeStandardised] like 'Hx' then case 
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Read and Modify (Own)'
			when ClaimValue like '2' then 'Read and Modify (Managed)'
			when ClaimValue like '3' then 'Read Only'
			when ClaimValue like '4' then 'Read and Modify (All)'
			end			
when [ClaimTypeStandardised] like 'l4' or [ClaimTypeStandardised] like 'l6' or [ClaimTypeStandardised] like 'l9' or [ClaimTypeStandardised] like 'l8' or [ClaimTypeStandardised] like 'lc' or [ClaimTypeStandardised] like 'l7' or [ClaimTypeStandardised] like 'l1' or [ClaimTypeStandardised] like 'l2' or [ClaimTypeStandardised] like 'lv' or [ClaimTypeStandardised] like 'As' or [ClaimTypeStandardised] like 'Ft' or [ClaimTypeStandardised] like 'Fc' or [ClaimTypeStandardised] like 'Ff' or [ClaimTypeStandardised] like 'Fa' or [ClaimTypeStandardised] like 'Ad' or [ClaimTypeStandardised] like 'lt' or [ClaimTypeStandardised] like 'lm' or [ClaimTypeStandardised] like 'li' or [ClaimTypeStandardised] like 'll' or [ClaimTypeStandardised] like 'ld' or [ClaimTypeStandardised] like 'lf' or [ClaimTypeStandardised] like 'le' or [ClaimTypeStandardised] like 'lj' or [ClaimTypeStandardised] like 'lk' or [ClaimTypeStandardised] like 'At' or [ClaimTypeStandardised] like 'lu' then case
			when ClaimValue like '1' then 'Yes'
			when ClaimValue like '0' then 'No'
			end
When [ClaimTypeStandardised] like 'l5' then case
			when ClaimValue like '0' then 'Cannot Edit Actions'
			when ClaimValue like '1' then 'Can Edit Own Actions Only'
			when ClaimValue like '3' then 'Can Edit All Actions'
			end
When [ClaimTypeStandardised] like 'lb' then case
			when ClaimValue like '0' then 'Cannot Edit Appointments'
			when ClaimValue like '1' then 'Can Edit Own Appointments Only'
			when ClaimValue like '3' then 'Can Edit All Appointments'
			end
When [ClaimTypeStandardised] like 'l3' then case
			when ClaimValue like '0' then 'No Access'
			when ClaimValue like '1' then 'Can Access'
			end 
when [ClaimTypeStandardised] like 'la' then case
			when ClaimValue like '0' then 'Not Visible'
			when ClaimValue like '1' then 'Visible'
			end 
when [ClaimTypeStandardised] like 'lr' then case
			when ClaimValue like '0' then 'Cannot Remove Appointments'
			when ClaimValue like '1' then 'Can Remove Own Appointments Only'
		    when ClaimValue like '3' then 'Can Remove All Appointments'
			end 
else ClaimValue
end as [Permission Value]


from(

select name as [Role] 
,ClaimValue
,case when ClaimType like 'Administration' then 'SA'
when ClaimType like 'Technician' then 'A'
when ClaimType like 'Ticket_Level' then 'Tx'
when ClaimType like 'Calendar_Level' then 'Ax'
when ClaimType like 'Customers_Level' then 'Ux'
when ClaimType like 'Sup_Lvl' then 'Sx'
when ClaimType like 'Ix' then 'Ix'
when ClaimType like 'Serv_Lvl' then 'Vx'
when ClaimType like 'Contract_Level' then 'Cx'
when ClaimType like 'Project_Level' then 'Px'
when ClaimType like 'Sales_Level' then 'Ox'
when ClaimType like 'Reporting_Level' then 'Rx'
when ClaimType like 'Software_Level' then 'Wx'
when ClaimType like 'KB_Level' then 'Bx'
when ClaimType like 'Assets_Level' then 'Dx'
when ClaimType like 'Timesheets_Level' then 'Hx'

when ClaimType like 'Chat_Lvl' then 'LC'
when ClaimType like 'PR' then 'PR'

when ClaimType like 'Advanced_Edit' then 'l1'
when ClaimType like 'Approvals_Can_Override' then 'l2'
when ClaimType like 'Approvals_Page_Access' then 'l3'
when ClaimType like 'Can_Remove_Tickets' then 'l4'
when ClaimType like 'Can_Edit_Actions' then 'l5'
when ClaimType like 'Can_Log_Tickets' then 'l6'
when ClaimType like 'Can_Reassign_Tickets' then 'l7'
when ClaimType like 'Can_View_Tech_Tickets' then 'l8'
when ClaimType like 'Can_View_Unassigned_Tickets' then 'l9'
when ClaimType like 'Edit_Preferences' then 'l0'
when ClaimType like 'Pwd_Level' then 'la'
when ClaimType like 'Can_Edit_Appointments' then 'lb'
when ClaimType like 'Can_Change_Ticket_Types' then 'lc'
when ClaimType like 'Can_View_Site_Docs' then 'D1'
else ClaimType
end as [ClaimTypeStandardised]


from NHD_RoleClaims
join NHD_Roles on NHD_Roles.Id=RoleId

)d
