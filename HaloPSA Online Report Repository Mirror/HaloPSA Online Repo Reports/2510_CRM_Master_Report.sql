select
faultid [Ticket ID]
, symptom [Summary]
, aareadesc [Client]
, dateoccured [Date Logged]
, tstatusdesc [Status]
, uname [Assigned Agent]
, rtdesc [Ticket Type]
, qhporef [Quote Reference]
, qhtitle [Quote Title]
, qhdate [Date Quoted]
, case 
when qhapprovalstate=0 then 'N/A'
when qhapprovalstate=1 then 'No'
when qhapprovalstate=2 then 'Yes'
end [Quote Approved?]
, (select sum(qdprice*qdquantity) from quotationdetail where qdqhid=qhid) [Total Price]

from faults
join tstatus on tstatus=status
join uname on unum=assignedtoint
join requesttype on rtid=requesttypenew
join area on aarea=areaint
join quotationheader on qhfaultid=faultid


where fdeleted=fmergedintofaultid and rtisopportunity=1

