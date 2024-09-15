select uusername as [User Name], uischangeapprover as [Approver?],aareadesc as [Customer] from users
left join site on usite=ssitenum
left join area on aarea=sarea
where aisinactive=0 and uischangeapprover=1
