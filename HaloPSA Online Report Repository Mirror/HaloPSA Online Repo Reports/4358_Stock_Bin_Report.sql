select STBID as [stockbin_id],STBName as [Stock Bin Name],aareadesc as [Customer],sdesc as [Site Name],* from stockbin
left join site on ssitenum=STBSsitenum
left join area on aarea=sarea
