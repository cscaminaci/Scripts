--DYNAMIC
declare @cols nvarchar(max)
set @cols =     (SELECT STUFF((
                select  ' , ' + '[' +
 cast(month_nm as nvarchar(100))+'-'+cast(date_year as nvarchar(100)) + ']'
 from calendar   where  date_day=1 and date_id between getdate()-365 and getdate() order by date_id
                FOR XML PATH('')
                    ,TYPE
                ).value('(./text())[1]', 'VARCHAR(MAX)'), 1, 2, '') AS NameValues)
set @cols =@cols+',[All]'
				print(@cols)

declare @sql nvarchar (max)
set @sql= '    
select * from 
(select gdesc as [Item Group] ,
cast(month_nm as nvarchar(100))+''-''+cast(date_year as nvarchar(100)) as [Dates],[Total] as [Total]
from calendar
cross join  generic

left join (
select sum(idnet_amount ) as [Total],igeneric,IHInvoice_Date from invoicedetail join invoiceheader on ihid=idihid join item on iid=ID_ItemID where ihid>0 group by ihinvoice_date,igeneric
)b on Ggeneric=Igeneric and datepart(MONTH,ihinvoice_date)=datepart(MONTH,date_id) and  datepart(YEAR,ihinvoice_date)=datepart(YEAR,date_id)

where  date_day=1 and date_id between getdate()-365 and getdate() 
and ggeneric in (117,116,115,109,110)
group by gdesc ,cast(month_nm as nvarchar(100))+''-''+cast(date_year as nvarchar(100)),[Total]
union all

select gdesc as [Item Group] ,
''All'',sum([Total]) as [Total]
from  generic

left join (
select sum(idnet_amount ) as [Total],igeneric,IHInvoice_Date from invoicedetail join invoiceheader on ihid=idihid join item on iid=ID_ItemID where ihid>0 group by ihinvoice_date,igeneric
)b on Ggeneric=Igeneric 

where   ihinvoice_date between getdate()-365 and getdate() 
and ggeneric in (117,116,115,109,110)
group by gdesc 
)pvt
PIVOT

(
MAX([Total]) for [dates] in ('+@cols+')
) pvt
'

exec (@sql)
