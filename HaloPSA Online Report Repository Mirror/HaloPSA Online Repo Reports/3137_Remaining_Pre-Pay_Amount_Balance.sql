select Client,[Total Used],[Top Up Total],[Top Up Total]-[Total Used] as [Balance]
from(
select aareadesc as [Client],
areaint,
round(isnull(sum(isnull(actionprepayamount,0)),0),2) as [Total Used],
(select isnull(sum(ppamount),0) from Prepayhistory where  ppareaint=areaint) as [Top Up Total]
from actions join faults on actions.faultid=faults.faultid join area on aarea=areaint
where  actionprepayhours>0 and fdeleted=fmergedintofaultid
group by aareadesc,areaint)b

