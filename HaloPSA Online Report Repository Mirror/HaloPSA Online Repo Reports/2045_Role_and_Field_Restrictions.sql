
SELECT TOP (10000) 
      
      rtdesc as [Ticket Type]
      ,filabel as [Field]
      ,Name as [Role]
  FROM [RequestTypeFieldRestriction]
left join fieldinfo on fiid=RTFRfieldid
left join requesttype on rtid=RTFRrtid
left join nhd_roles on IdInt=RTFRroleid
