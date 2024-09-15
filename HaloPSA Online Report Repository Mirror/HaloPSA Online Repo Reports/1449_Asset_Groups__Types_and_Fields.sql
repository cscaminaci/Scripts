select gdesc as [Asset Group]
,tdesc as [Asset Type]
,Yname as [Field Name]

from GENERIC
join xtype on Ggeneric=Tgeneric
join TYPEINFO on TTypenum=xnum
join field on Xfieldnos=Yseq
where Xkind ='T'
and ykind='T'
