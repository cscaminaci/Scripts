SELECT TOP (1000000) 
     
        LDesc as [Licence Description]
      , [LCount] as [Count]
	  , aareadesc as [Customer]
	  , sdesc as [Site]
      , [LPurchasePrice] as [Purchase Price]
      , [LPurchaseDate] as [Purchase Date]
      , [LVendor] as [Vendor]
      , [LManufacturer] as [Manufacturer]
      , [LNotes] as [Notes]
      , [LDueDate] as [Due Date]
	  , IdIHid as 'Linked Invoice ID'
  FROM [Licence]
left join area on larea=aarea
left join site on lsite=ssitenum
LEFT JOIN InvoiceDetailQuantity ON IDQLicenceId = lid
LEFT JOIN INVOICEDETAIL ON idqidid = idid
WHERE idihid IS NULL
