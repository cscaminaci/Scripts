select faultid as [Ticket Number]
    , dinvno as [Asset Tag]
    , (select aareadesc from area where areaint=aarea) as [Area]
    , dateoccured as [Date Occurred]
    , datecleared as [Date Cleared]
    , symptom as [Symptom]
    , (select tstatusdesc from tstatus where tstatus=status) as [Status]
    , clearance as [Clearance]
    , (select uname from uname where unum=assignedtoint) as [Technician]


from faults join device on devsite=dsite and devicenumber=ddevnum                                         
where datecleared>getdate()-14 and
(select count(faultid) from faults b where b.datecleared>getdate()-14 and b.devsite=dsite and b.devicenumber=ddevnum)>1


