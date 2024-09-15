select * from

(

select [Client], sum([+ve Sum] - [-ve Sum]) as [Active Pre-Pay Balance]

from

(

select sum(pphours) as [+ve Sum], aareadesc as [Client],

(select sum(ActionPrePayHours) from actions

left join faults on actions.faultid=faults.faultid
where faults.areaint=ppareaint) as [-ve Sum] 

from prepayhistory

left join area on prepayhistory.ppareaint=area.aarea

group by aareadesc, ppareaint

)a

group by a.[Client]
)b

/* Change the below number, i.e. 4 in this case to modify the number of hours that are needed for the report to be sent.
If the value is 4, then only clients with a pre-pay balance of less than 4 hours would appear on the report, therefore an email
would only be sent if a client with less than 4 hours appears here */

where [Active Pre-Pay Balance] < 4
