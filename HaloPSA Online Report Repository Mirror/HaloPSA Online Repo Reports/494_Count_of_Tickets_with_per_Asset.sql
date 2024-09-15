select count(faultid) as Count,dinvno as [Asset Tag],tdesc as Type from faults left join device on dsite=devsite
and ddevnum=devicenumber left join xtype on dtype=ttypenum where devicenumber>0 and fdeleted=0 and dateoccured>@startdate
group by cast(devsite as nvarchar(10))+'-'+cast(devicenumber as nvarchar(10)),tdesc,dinvno
                                          

