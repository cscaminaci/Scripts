select (select aareadesc from area where areaint=aarea )as Client, actions.faultid as TicketID, actionnumber as ActionNumber, actoutcome as Action, note as Note, Whe_ as Date from ACTIONS join faults on actions.faultid=faults.faultid where whe_>@startdate and whe_<@enddate   

