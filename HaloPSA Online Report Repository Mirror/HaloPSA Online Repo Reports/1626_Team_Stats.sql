select SDSectionName 
,[Incidents Logged]
,[Incidents Closed]
,round(cast([Incidents Response SLA] as float)/nullif(cast([Incidents Closed] as float),0)*100,2) as [Incidents Response SLA%]
,round(cast([Incidents Resolution SLA] as float)/nullif(cast([Incidents Closed] as float),0)*100,2) as [Incidents Resolution SLA%]
,[Requests Logged]
,[Requests Closed]
,round(cast([Requests Response SLA] as float)/nullif(cast([Requests Closed] as float),0)*100,2) as [Requests Response SLA%]
,round(cast([Requests Resolution SLA] as float)/nullif(cast([Requests Closed] as float),0)*100,2) as [Requests Resolution SLA%]



from sectiondetail
left join (select sectio_ [ITeam], count(faultid) [Incidents Logged] from faults where requesttype=1 and fdeleted=0 and FMergedIntoFaultid=0 and dateoccured>@startdate and dateoccured<@enddate group by sectio_)a on SDSectionName=[ITeam]
left join (select sectio_ [RTeam], count(faultid) [Requests Logged] from faults where requesttype=3 and fdeleted=0 and FMergedIntoFaultid=0 and dateoccured>@startdate and dateoccured<@enddate  group by sectio_)b on SDSectionName=[RTeam]
left join (select sectio_ [ICTeam], count(faultid) [Incidents Closed] from faults where requesttype=1 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate  group by sectio_)c on SDSectionName=[ICTeam]
left join (select sectio_ [RCTeam], count(faultid) [Requests Closed] from faults where requesttype=3 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate  group by sectio_)d on SDSectionName=[RCTeam]
left join (select sectio_ [IResponseTeam], count(faultid) [Incidents Response SLA] from faults where SLAresponseState='I' and requesttype=1 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate  group by sectio_)e on SDSectionName=[IResponseTeam]
left join (select sectio_ [RResponseTeam], count(faultid) [Requests Response SLA] from faults where SLAresponseState='I' and requesttype=3 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate group by sectio_)f on SDSectionName=[RResponseTeam]
left join (select sectio_ [IFixTeam], count(faultid) [Incidents Resolution SLA] from faults where Slastate='I' and requesttype=1 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate  group by sectio_)g on SDSectionName=[IFixTeam]
left join (select sectio_ [RFixTeam], count(faultid) [Requests Resolution SLA] from faults where Slastate='I' and requesttype=3 and fdeleted=0 and FMergedIntoFaultid=0 and datecleared>@startdate and datecleared<@enddate  group by sectio_)h on SDSectionName=[RFixTeam]

