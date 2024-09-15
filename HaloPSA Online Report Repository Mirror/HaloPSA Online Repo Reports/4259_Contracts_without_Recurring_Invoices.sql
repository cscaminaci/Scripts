select chcontractref as [Contract Ref],  aareadesc as [Client] from CONTRACTHEADER ch join area a on ch.charea = a.Aarea
where chid not in (select ihchid from INVOICEHEADER a)

