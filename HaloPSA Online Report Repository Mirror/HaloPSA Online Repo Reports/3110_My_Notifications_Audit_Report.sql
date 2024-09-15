SELECT top 1000
	  emdate as 'Date'
	, EMmessage as 'Message'
	, (SELECT uname FROM uname WHERE emuserid = unum) as 'Agent'
	, EMfaultid as 'Ticket ID'
FROM escmsg
WHERE EMshown = 1
  AND emuserid = $AGENTID
ORDER BY emdate DESC
