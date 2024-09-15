select

count (act1.actoutcome) as [Re-Assign Count],
sectio_ as [Team],
who as [Agent],
case when fbscore=1 then 'Excellent'
when fbscore=2 then 'Good'
when fbscore=3 then 'OK'
else 'Bad' end  as [Score],fbdate as [Date],
fbcomment as [Comment],
fbfaultid as [Ticket ID]

FROM actions act1
JOIN faults ON act1.faultid = faults.faultid
JOIN feedback on faults.faultid = fbfaultid

WHERE act1.actoutcome = 'Re-Assign'
AND fbsubject='Feedback From Ticket'

GROUP BY sectio_, who, fbfaultid, fbscore, fbdate, fbcomment
