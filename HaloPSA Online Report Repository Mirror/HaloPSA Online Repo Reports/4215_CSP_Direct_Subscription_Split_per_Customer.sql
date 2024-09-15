select LTenantName as [CSP Tenant Name], aareadesc as [Customer Name], Ldesc as [Description], Lcount as [Quantity], cast(LPurchaseDate as date) as [Start Date], cast(Lduedate as date) as [End Date], cast(LBillingCycle as nvarchar) as [Billing Cycle], cast(ltermduration as nvarchar) as [Term Duration], cast(lautorenew as nvarchar) as [Auto-Renew], cast(Lstatus as nvarchar) as [Status] from licence

left join area on Larea=aarea

 where ltype=1 and lstatus not like 'Deleted'

/* Ldesc as [Description], Lcount as [Quantity],LTenantName as [CSP Tenant Name], LPurchaseDate as [Start Date], Lduedate as [End Date], LBillingCycle as [Billing Cycle], ltermduration as [Term Duration], lautorenew as [Auto-Renew], Lstatus as [Status], */
