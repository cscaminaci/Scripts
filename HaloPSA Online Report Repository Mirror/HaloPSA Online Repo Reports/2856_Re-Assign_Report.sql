select * from (

select [Ticket ID], who as [Who], [Trim Before] as [Assigned To],[Trim After] as [Assigned From],[Action Number], [Currently Assigned], [Note], whe_ as [Re-Assign Date], ROW_NUMBER() OVER(partition by [Ticket ID] ORDER BY [Action Number] asc) AS Row, LAG(whe_) over(partition by [Ticket ID] order by [Action Number] desc) as [Next Re-Assign]


 from(

select actions.faultid as [Ticket ID]
, whe_
, actionnumber as [Action Number]
, note as [Note]
, who
, SUBSTRING(cast(note as nvarchar(max)),CHARINDEX('To',cast(note as nvarchar(max))),LEN(cast(note as nvarchar(max)))) as [Trim After]
, SUBSTRING(note,0,CHARINDEX(';',note,0)) as [Trim Before]
, uname as [Currently Assigned]

from actions

join faults on faults.faultid = actions.faultid
join uname on unum=assignedtoint

where actoutcome like 're-assign')a

)b

where [Re-Assign Date] between @startdate and @enddate

