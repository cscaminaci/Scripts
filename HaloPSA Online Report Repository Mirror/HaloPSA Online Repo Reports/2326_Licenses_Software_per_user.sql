SELECT TOP (1000000) 
     
      lDesc as [Licence Description]
      ,[LCount] as [Count]
  
,aareadesc as [Customer]
   
,sdesc as [Site]
      ,[LPurchasePrice] as [Purchase Price]

,COUNT (dauserid) as [Quantity]
,ssitenum as [Site ID]    


  FROM [Licence]
  join deviceapplications on datype=lid
  join users on uid=dauserid
  join site on usite=ssitenum
  join area on sarea=aarea

where  dauserid>0

group by ldesc,lcount,aareadesc,sdesc,lpurchaseprice,ssitenum
