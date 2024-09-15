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
select 
area.aareadesc as [Asset Area],
site.sdesc as [Asset Site],


site.ssitenum as [Asset Site Number],
site.sdatecreated as [Site Date Created],

uid as [UID of Linked User],
uusername as [Username],
fvalue as [Asset Status],
custarea.aareadesc as [Customer Area],
custsite.sdesc as [Customer Site],
 
pvt.* from 
(
select 

dinvno as [Device Number],
cast(Dmemo as nvarchar(1000)) as [Memo],
tdesc as [Asset Type],
dsite,
yname,
idata value1
,ddevnum
,dinactive
,dstatus
,STUFF((SELECT '', '' + CAST(a.dinvno AS VARCHAR(100)) [text()]
         FROM devicechild join device a on a.did=dccid
         WHERE dcid=device.did
         FOR XML PATH(''''), TYPE)
        .value(''.'',''NVARCHAR(MAX)''),1,2,'' '') as [Child Assets]

from device

left join xtype on dtype=ttypenum
join typeinfo on ttypenum=xnum
left join field on ykind=''t'' and yseq=xfieldnos
left join info on ikind = ''d'' and  isite=dsite and inum=ddevnum and iseq=xseq

) src
PIVOT
(
MAX(value1) for yname in ('+@cols+')
) pvt


left join site on site.ssitenum=dsite
left join area on area.aarea=site.sarea
left join userdevice on ddevnum=uddevnum and dsite=uddevsite
inner join users on udsite=usite and udusername=uusername and dinactive=0
left join lookup on fid=61 and fcode=dstatus
left join site custsite on custsite.ssitenum=usite
left join area custarea on custarea.aarea=custsite.sarea

'

exec (@sql)


