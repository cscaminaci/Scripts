--DYNAMIC
declare @ColumnNames nvarchar(max)=N''
declare @ColumnNames2 nvarchar(max)=N''
declare @sql nvarchar(max) = N''
select @ColumnNames = @ColumnNames+', ['+coalesce(uname,'') +']' From
       (select distinct uname from uname where uisdisabled = 0)dt
select @ColumnNames = LTRIM(STUFF(@ColumnNames,1,1,''))
select @ColumnNames2 = @ColumnNames2+', round( ['+coalesce(uname,'') +'], 3) as ['+coalesce(uname,'') +']' From
       (select distinct uname from uname where uisdisabled = 0)dt
select @ColumnNames2 = LTRIM(STUFF(@ColumnNames2,1,1,''))
set @sql=
N'select [Request Type], '+@ColumnNames2+' from (select who, rtdesc as [Request Type], count(distinct actions.faultid) as timetaken from RequestType 
left join faults on requesttypenew=rtid and status= 9 and datecleared between '@startdate' and '@enddate'
left join actions on faults.faultid=actions.faultid and who in (select uname from uname where uisdisabled = 0)
group by who, rtdesc
)pvt
pivot
(sum(timetaken)
for who in ('+@ColumnNames+')) as pvt';
exec (@sql)
