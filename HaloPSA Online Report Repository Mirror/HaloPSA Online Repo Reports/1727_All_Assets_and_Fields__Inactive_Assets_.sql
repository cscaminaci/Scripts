--DYNAMIC SQL
declare @cols nvarchar(max)
set @cols =     (SELECT STUFF((
                select distinct ' , ' + '[' +
 yname + ']'
 from device left join xtype on ttypenum=dtype left join typeinfo on ttypenum=xnum
left join field on ykind='t' and yseq=xfieldnos
left join info on ikind = 'd' and  isite=dsite and inum=ddevnum and iseq=xseq
                FOR XML PATH('')
                    ,TYPE
                ).value('(./text())[1]', 'VARCHAR(MAX)'), 1, 2, '') AS NameValues)

declare @sql nvarchar (max)
set @sql= '    
select * from 
(select                       
(select aareadesc from area where aarea = sarea) as [Area]
,sdesc as [Site]
,dinvno as [Asset Tag]
,tdesc as [Asset Type]
,yname
,idata as [Value2]
 from device left join xtype on ttypenum=dtype left join typeinfo on ttypenum=xnum
left join field on ykind=''t'' and yseq=xfieldnos
left join info on ikind = ''d'' and  isite=dsite and inum=ddevnum and iseq=xseq
left join site on dsite=ssitenum
where dinactive=1
) src
PIVOT
(
MAX(value2) for yname in ('+@cols+')
) pvt'

exec (@sql)





