--DYNAMIC SQL
declare @cols nvarchar(max)
set @cols =     (SELECT STUFF((
                select distinct ' , ' + '[' +
 yname + ']'
 from device left join xtype on ttypenum=dtype left join typeinfo on ttypenum=xnum
left join field on ykind='t' and yseq=xfieldnos
left join info on ikind = 'd' and  isite=dsite and inum=ddevnum and iseq=xseq where yname!=''
                FOR XML PATH('')
                    ,TYPE
                ).value('(./text())[1]', 'VARCHAR(MAX)'), 1, 2, '') AS NameValues)
				print(@cols)
				
declare @sql nvarchar (max)
set @sql= '    
select aareadesc as [Area]
,sdesc as [Device Site],
udusername as [User],
* from 
(select                       
dinvno as [Asset Tag]
,tdesc as [Asset Type]
,yname
,dsite
,ddevnum
,idata as [Value2]
 from device left join xtype on ttypenum=dtype left join typeinfo on ttypenum=xnum
left join field on ykind=''t'' and yseq=xfieldnos
left join info on ikind = ''d'' and  isite=dsite and inum=ddevnum and iseq=xseq

) src
PIVOT
(
MAX(value2) for yname in ('+@cols+')
) pvt
left join site on dsite=ssitenum
left join userdevice on uddevsite=dsite and uddevnum=ddevnum
Join area on aarea=sarea'

exec (@sql)





