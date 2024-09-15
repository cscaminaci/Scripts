select fhname from FLOWHEADER where FHName not in (
select FHName from REQUESTTYPE
join FLOWHEADER on REQUESTTYPE.RTWorkFlowID=FHID)
