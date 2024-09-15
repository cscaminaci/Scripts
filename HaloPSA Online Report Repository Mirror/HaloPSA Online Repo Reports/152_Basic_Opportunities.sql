 select faultid as [Ticket_ID] ,
symptom as [Subject],
foppcompanyname as [Client],
foppcontactname as [Customer],
foppemailaddress,
dateoccured as [Date_occurred],
foppvalue as [Potential_Value],
foppconversionprobability as [Conversion_Probability],
(foppvalue*(foppconversionprobability/100)) as [Opportunity_Value] ,
(select uname from uname where unum=assignedtoint) as [Technician]
from faults where  requesttypenew in (select rtid from requesttype where RTIsOpportunity='true')




