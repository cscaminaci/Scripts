select

ihid as [Recurring Invoice URL ID],
aareadesc as [Client],
IDItem_ShortDescription as [Line Item],
case 
when idqprorata = 0 then 'Include Changes in Next Invoice'
when idqprorata = 1 then 'Pro Rata from the date the change occurred'
when idqprorata = 2 then 'Exclude changes from the next invoice'
when idqprorata = 3 then 'Immediately invoice for changes'
when idqprorata = 4 then 'Prorate any changes and add to Ready for Invoicing'
end as [ProRata Plan]


from invoiceheader
join invoicedetail on idihid = ihid
join invoicedetailquantity on IDQIDid=idid
join area on ihaarea=aarea
