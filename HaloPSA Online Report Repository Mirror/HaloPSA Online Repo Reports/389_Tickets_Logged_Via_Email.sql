select
      aareadesc as [Customer]
    , (select count(*) from faults where frequestsource=0 and aarea=areaint and dateoccured > @startdate and 
dateoccured < @enddate) as [Logged via Email]                               
from 
      Area
                                                                                       


