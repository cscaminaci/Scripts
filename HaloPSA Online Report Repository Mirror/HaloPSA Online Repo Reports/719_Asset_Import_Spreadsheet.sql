--DYNAMIC SQL
declare @cols nvarchar(max)
set @cols =     (SELECT STUFF((
                select distinct ' , ' + '[' +
 yname + ']'
 from device join xtype on ttypenum=dtype join typeinfo on ttypenum=xnum
join field on ykind='t' and yseq=xfieldnos
join info on ikind = 'd' and  isite=dsite and inum=ddevnum and iseq=xseq
                FOR XML PATH('')
                    ,TYPE
                ).value('(./text())[1]', 'VARCHAR(MAX)'), 1, 2, '') AS NameValues)

declare @sql nvarchar (max)
set @sql= '    
select (select aareadesc from area where aarea = sarea) as [Area]
,sdesc as [Asset Site]
,(select sldesc from slahead where slid=dslaid) as [SLA Description]
,(select sldesc from slahead where slid=dsupplierslaid) as [Supplier SLA Description]
,(select pdesc from policy where ppolicy=DSupplierPriorityID and pslaid=dsupplierslaid) as [Supplier Priority Description]
,udusername as [Linked User] 
,* from 
(select     
tdesc as [Asset Type]                 
,dinvno as [Inventory Number]
,cast(dmemo as nvarchar(2000)) as [Memo]
,DSupplierPurchaseDate as [Supplier Start Date]
,DSupplierExpiryDate as [Supplier End Date]
,DSupplierReference as [Supplier Reference]
,yname
,dsite,ddevnum
,dsupplierslaid
,dslaid
,DSupplierPriorityID 
,idata as [Value1]
 from device join xtype on ttypenum=dtype left join typeinfo on ttypenum=xnum
left join field on ykind=''t'' and yseq=xfieldnos
left join info on ikind = ''d'' and  isite=dsite and inum=ddevnum and iseq=xseq
) src
PIVOT
(
MAX(value1) for yname in ('+@cols+')
) pvt
left join site on dsite=ssitenum
outer apply (select top 1 udusername from userdevice where uddevnum=ddevnum and udsite=dsite) TOPUSER'

exec (@sql)


