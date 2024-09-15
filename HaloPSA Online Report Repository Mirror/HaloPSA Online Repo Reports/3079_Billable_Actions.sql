SELECT TOP 1000
row_number() OVER (ORDER BY faults.faultid) [ID],
FORMAT (whe_,'dd.MM.yy') [Date],
faults.faultid [Ticket ID],
FInvoiceSeperatelyOverride [Billed Separately],
'Ticket-ID: ' + CONVERT (nvarchar(255), faults.faultid) + '  -  ' + CONVERT (nvarchar(255), symptom) [Ticket],
symptom [title],
note [note],
actioncode,
(SELECT top 1 crrate FROM chargerate WHERE crchargeid=actioncode+1 and crarea=faults.areaint ORDER BY crStartdate DESC) [Charge Rate],
round(actionchargehours,2) [Billable Time]
FROM actions a
left JOIN faults ON faults.faultid=a.faultid
WHERE fdeleted=fmergedintofaultid and actioninvoicenumber=$invoiceid and actionchargehours > 0

