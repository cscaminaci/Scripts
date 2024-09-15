SELECT
      (select uname from uname where clearwhoint = unum) as [Agent]
    , (select RTDesc from RequestType where RTID = RequestTypeNew) as [Ticket Type]
    , count(*) AS [Tickets Closed]
FROM                                        
      faults
WHERE
      datecleared > @startdate
     AND datecleared < @enddate 
     AND fdeleted = 0
     AND fmergedintofaultid = 0
GROUP BY 
      RequestTypeNew
    , clearwhoint 

