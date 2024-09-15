select DCID as [ID]
,aareadesc as [Entity]
,sdesc as [Site]
,dinvno as [Asset Tag]
,Yname as [Field]
,DCOldValue as [Old Value]
,DCNewValue as [New Value]
,DCWhen as [Date]
,dcwho as [Who]
from 
devicechange
join field on dcfieldid=yseq and ykind='t'
join DEVICE on DCDSite=Dsite and DCDevNum=ddevnum
join site on ssitenum=DCDSite
join area on sarea=Aarea
and DCFieldID>0
