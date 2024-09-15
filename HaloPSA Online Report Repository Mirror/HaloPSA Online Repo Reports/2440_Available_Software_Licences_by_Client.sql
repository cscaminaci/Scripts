select 

aareadesc as [Customer]
,dadesc as [Licence Type]
,count(dadesc) as [Assigned Licence Count]
,lcount as [Licence Count]
,lcount-(count(dadesc)) as [Available Licences]

from deviceapplications
left join users on uid=dauserid
left join site on ssitenum=usite
left join area on aarea=sarea
left join licence on datype=lid
where dadesc <> 'Microsoft Teams Exploratory' AND dadesc <> 'Microsoft Power Automate Free' AND dadesc <> 'Power BI (free)'
group by aareadesc,dadesc,lcount
