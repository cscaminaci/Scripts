SELECT DISTINCT
  fbusername AS [User],
  fbfaultid AS [Ticket ID],
  CASE
    WHEN fbscore = 1 THEN 'Excellent'
    WHEN fbscore = 2 THEN 'Good'
    WHEN fbscore = 3 THEN 'OK'
    ELSE 'Bad'
  END AS [Score],
  fbdate AS [Date],
  fbcomment AS [Comment],
  sectio_ as [Team],
  uname AS [Agent],
  sdesc AS [Site],
  rtdesc AS [Ticket Type],
  sldesc AS [SLA],
  pdesc AS [Priority]
FROM
  feedback
JOIN faults ON fbfaultid = faultid
JOIN uname ON unum = clearwhoint
JOIN site ON sitenumber = ssitenum
JOIN requesttype ON rtid = requesttypenew
JOIN slahead on slid = slaid
JOIN policy ON ppolicy = seriousness AND pslaid = slaid
WHERE
  fbsubject = 'Feedback From Ticket'

