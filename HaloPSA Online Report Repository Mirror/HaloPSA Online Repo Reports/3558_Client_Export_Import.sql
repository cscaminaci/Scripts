select 
treedesc TopLevel
,aareadesc CustomerName    
,aaccountsid AccountsID
,sdesc  SiteName    
,ASLine1 [Addressline1]    ,ASLine2 [Addressline2]    ,ASLine3 [Addressline3]    ,ASLine4 [Addressline4]    , ASLine5 [Postcode] , SPhoneNumber [SitePhoneNumber], SiteEmailDomain,    smemo [SiteMemo]
, AXeroTenantId [Xero_tenant_id]
, AXeroID [xeroid]
, atradingname [trading_name]
, AAccountsFirstName [accountsfirstname]
, AAccountsLastName [accountslastname]
, AAccountsEmailAddress [accountsemailaddress]
, ANONSLAtaxcode [sales_tax_code]
, APurchasesTaxCode [purchase_tax_code]
, AContractTemplateID [billing_template_id]
from site 
join area on aarea=sarea join tree on treeid=atreeid
left join addressstore on assiteid=ssitenum and astype=-2
where aisinactive=0 and aarea not in (1,12)
