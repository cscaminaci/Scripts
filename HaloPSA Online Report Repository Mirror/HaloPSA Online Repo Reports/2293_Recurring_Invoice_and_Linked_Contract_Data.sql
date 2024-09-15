select 
ihid as [Recurring Invoice ID],
aareadesc as [Customer Name],
stdnextcreationdate as [Next Invoice Creation],
case
when stdperiod= 1 then 'Weekly'
when stdperiod= 2 then 'Monthly'
when stdperiod= 4 then 'Quarterly'
when stdperiod= 5 then '6-Monthly'
when stdperiod= 3 then 'Yearly'
when stdperiod= 8 then '2 Yearly'
END as [Period],
case when ihprorataperiodsahead = 0  then 'Previous Period'
when ihprorataperiodsahead = 1  then 'Current Period'
when ihprorataperiodsahead = 2  then 'Next Period'
when rprorataperiodsahead = 0  then 'Previous Period'
when rprorataperiodsahead = 1  then 'Current Period'
when rprorataperiodsahead = 2  then 'Next Period'
else 'Previous Period' end as [Relative Period],
iditem_shortdescription as [Line Description],
gdesc as [Item Group],
idqty_order as [Quantity],
idunit_price as [Unit Price],
IDNet_amount as [Net Price],
chcontractref as [Contract Ref],
CHstartdate as [Contract Start Date],
CHenddate as [Contract End Date]
from invoicedetail
join invoiceheader on ihid=idihid 
join area on ihaarea=aarea
left join item on iid=id_itemid
left join generic on ggeneric=igeneric
left join STDREQUEST on ihid=stdinvoiceid
left join contractheader on ihchid=chid
join control2 on 1=1
where ihid<0
