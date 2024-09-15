SELECT TOP (1000000) 
     
      LDesc as [Licence Description]
      ,[LCount] as [Count]
  
,aareadesc as [Customer]
   
,sdesc as [Site]
      ,[LPurchasePrice] as [Purchase Price]
      ,[LPurchaseDate] as [Purchase Date]
      
      ,[LVendor] as [Vendor]
      ,[LManufacturer] as [Manufacturer]
      ,[LNotes] as [Notes]
      
      ,[LDueDate] as [Due Date]
  FROM [Licence]
left join area on larea=aarea
left join site on lsite=ssitenum
where larea=$clientid
