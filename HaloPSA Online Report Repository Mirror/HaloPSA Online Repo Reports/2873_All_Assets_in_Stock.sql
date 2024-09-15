select dinvno as [Asset Tag], isdate as [Received Date], iscost as [Cost], idesc as [Product],   (select idata from info where isite = dsite and inum=ddevnum and iseq=(select xseq from typeinfo where xfieldnos=117 and xnum=dtype)) as [Serial Number], shporef as [PO Number] from device
join itemstock on ditemstockid=isid
join site on dsite=ssitenum and sisstocklocation=1
join item on isiid=iid
join supplierorderheader on isshid=shid
where ditemstockid > 0
