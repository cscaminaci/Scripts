SELECT aareadesc AS [ClientName]
    ,sdesc AS [SiteName]
    ,uusername [UserName]
    ,uFirstName as [FirstName]
	,uLastName as [LastName]
	,UTitle as [Title]
    ,isnull(ulogin, '') AS [NetworkLogin]    
    ,isnull(uextn, '') AS [PhoneNumber]
    ,isnull(umobile, '') AS [MobileNumber]
	,isnull(umobile2, '') AS [MobileNumber2]
	,isnull(utelhome, '') AS [homenumber]
	,CASE WHEN utelpref = 0 THEN uextn
		  WHEN utelpref = 1 THEN SPhoneNumber 
		  WHEN utelpref = 2 THEN umobile2
		  WHEN utelpref = 3 THEN utelhome
		  WHEN utelpref = 4 THEN umobile
	 END AS [phonenumber_preferred]
    ,isnull(ufax, '') AS [Fax]
    ,isnull(uemail, '') AS [EmailAddress]
    ,isnull(uemail2, '') AS [email2]
    ,isnull(uemail3, '') AS [email3]
    ,isnull(unotes, '') AS [Notes]
    ,isnull(uother1, '') AS [other1]
    ,isnull(uother2, '') AS [other2]
    ,isnull(uother3, '') AS [other3]
    ,isnull(uother4, '') AS [other4]
    ,isnull(uother5, '') AS [other5]
    ,uisserviceaccount as [isserviceaccount]
    ,uignoreautomatedbilling as [ignoreautomatedbilling]
    ,uinactive as [inactive]
    ,uunsubscribed as [unsubscribed]
    ,UDelegationActivated as [delegation_activated]
    ,UNeverSendEmails as [neversendemails]
    ,umessagegroup as [messagegroup_id]
    ,udontackemails as [dontackemails2]
    ,UisContractContact as [iscontractcontact]
    ,UisChangeApprover as [ischangeapprover2]
    ,UIsImportantContact as [isimportantcontact2]
    ,uallowviewclientdocs as [allowviewclientdocs]
    ,UAllowViewSiteDocs as [allowviewsitedocs]
    ,Ucanaccesscatalog as [canaccesscatalog]
    ,ucanaccessinvoices as [canaccessinvoices]
    ,UcanAdd as [canadd]
    ,UCanViewContracts as [canviewcontracts]
    ,ucanviewopps as [canviewopps]
    ,Ucataloglevel as [cataloglevel]
    ,udevicescope as [device_access_level]
    ,Uviewscope as [web_access_level]
FROM users
LEFT JOIN site ON usite = ssitenum
LEFT JOIN area ON sarea = aarea
WHERE uusername <> (
        SELECT rgeneraluser
        FROM control2
        )
