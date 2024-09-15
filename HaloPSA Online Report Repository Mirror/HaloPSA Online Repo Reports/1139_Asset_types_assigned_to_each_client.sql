select aareadesc as [Client],tdesc as [Asset Type], count(*) as [Number assigned]
from devicechange 
	left join site on ssitenum=DCDSite 
	left join area on sarea=aarea
	left join device on dcdsite=dsite and DCDevNum=ddevnum
	left join xtype on dtype=ttypenum
where dcfieldid=-2 and dcwhen>@startdate and DCWhen<@enddate  group by aarea, aareadesc, tdesc
