select aareadesc as [Client]
,sdesc [site]
,username [User]
,dateoccured [Date Created]
,symptom [Summary]
,rtdesc [Ticket Type]
,faultid [Ticket ID]


from faults
join requesttype on requesttypenew=rtid
join site on ssitenum=sitenumber
join area on aarea=areaint
where fdeleted = 0

