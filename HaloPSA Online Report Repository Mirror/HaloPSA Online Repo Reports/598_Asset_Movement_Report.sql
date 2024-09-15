select *,round(cast(case when [Old Location Date] is null then getdate()-[New Location Date] else
[New Location Date]-[Old Location Date] end as float),0) as [Days in Current Location] from
(select 
dinvno as [Asset Tag],
aareadesc as [Client], 
sdesc as [Site], 
(select top 1 udusername from userdevice where uddevsite=dsite and  uddevnum=ddevnum) as 'User',      
(select tdesc from xtype where ttypenum=dtype) as 'Type', 
(Select idata from info where ikind='d' and isite=dsite and inum=ddevnum and        
 iseq=(select xseq from typeinfo where xnum=dtype and xfieldnos=(select yseq from field where yname 
='Model')))Model, 
 (Select idata from info where ikind='d' and isite=dsite and inum=ddevnum and        
 iseq=(select xseq from typeinfo where xnum=dtype and xfieldnos=(select yseq from field where yname 
='Manufacturer')))Manufacturer,
 dcwhen as [New Location Date],
 (select top 1 dcwhen from DeviceChange where dcdsite=dsite and dcdevnum=ddevnum and dcfieldid=-2 and 
dcid<>(select top 1 dcid from DeviceChange where dcdsite=dsite and dcdevnum=ddevnum and dcfieldid=-2 order by 
dcwhen desc)order by dcwhen desc)  as [Old Location Date],
 dcoldvalue as [Old Location]
 from  device join site on Ssitenum=dsite join area on aarea=sarea 
 join DeviceChange on dcid=(select top 1 dcid from DeviceChange where dcdsite=dsite and dcdevnum=ddevnum and 
dcfieldid=-2 order by dcwhen desc))b 

