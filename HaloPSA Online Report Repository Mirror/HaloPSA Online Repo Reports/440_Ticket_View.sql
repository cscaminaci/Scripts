    select request_view.*,sectio_ as Section,category2 as [Category 1],category3 as [Category 2],category4 as [Category 3],category5 as [Category 4],satisfactionlevel as [Survey_Rating]  from request_view
join faults on faultid=ticket_id          
                                       


