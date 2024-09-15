select 
aareadesc as 'CustomerName', 
aaccountsid as 'AccountsID',
AAccountsFirstName as 'AccountsFirstName',
AAccountsLastName as 'AccountsLastName',
AAccountsEmailAddress as 'AccountsEmailAddress', 
AAccountsCCEmailAddress as 'AccountsCCEmailAddress',
aaccountsbccemailaddress as 'AccountsBCCEmailAddress'
 from area where AIsInactive='FALSE' and aarea not in (1,12)
