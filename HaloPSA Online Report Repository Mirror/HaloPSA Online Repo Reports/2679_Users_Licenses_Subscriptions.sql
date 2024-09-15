select 
uusername as [Username] 
,uemail as [Email]
,aareadesc as [Customer]
,uinactive as [Inactive]
,sdesc as [Site],
STUFF((SELECT ' | ' + CAST(dadesc AS VARCHAR(1000)) [text()]
         FROM deviceapplications 
         WHERE dauserid = da.dauserid 
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') [Licenses]
from deviceapplications da
left join users on uid=dauserid
left join site on ssitenum=usite
left join area on aarea=sarea
where dauserid >0
group by aareadesc,uusername,uemail,sdesc,dauserid,uinactive
