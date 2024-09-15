Select 
cast('Items Issued' as nvarchar) as [Type],
flid as [Ticket Number],
'' as [Contract],
Null as [Details],
dateoccured as [Date],
aareadesc as [Client], 
symptom as [Title],
null as [Hours],
cast(sum(FLorderqty*FLSellingPrice) as money) as [Price]

from faultitem
left join faults on flid=faultid
join area on aarea=areaint

where flstatus is null and fdeleted=0 and FLdateshipped between @startdate and @enddate and fitemsarebillable='true'

group by flid,dateoccured,aareadesc,symptom

UNION ALL

select 

'Sales Orders' as [Type],
OHfaultid as [Ticket Number],
Null,
'Order Number: ' + cast(ohid as nvarchar) as [Details],
OHorderdate as [Date],
aareadesc as [Client],
OHtitle as [Title],
null as [Hours],
cast((select sum(OLorderqty*OLSellingPrice) from orderline where olid=ohid) as money) as [Price]

from orderhead

left join site on ohsitenum=ssitenum
left join area on aarea=sarea
left join invoiceheader on ihid=OHInvoiceNumber
where ihpercent<100 or ihpercent is null and aarea!=12 and OHDoNotInvoice='False' and (select Fvalue4 from lookup where fid=34 and fcode=OHUserStatus)=1 and OHorderdate between @startdate and @enddate

UNION ALL

Select
'Recurring Invoices',
null,
null,
'Invoice ID: ' + CAST(IHID AS NVARCHAR),
STDNextCreationDate,
AAREADESC,
IHname,
null,
cast((select sum(IDNet_Amount + IDTax_Amount) from invoicedetail where idihid=ihid) as money)

FROM invoiceheader
JOIN STDREQUEST ON StdInvoiceId=IHID
JOIN AREA ON AAREA=IHaarea

WHERE (STDNextCreationDate BETWEEN @STARTDATE AND @ENDDATE OR STDNextCreationDate<@STARTDATE) AND STDNextCreationDate < GETDATE()


UNION ALL

SELECT 
[Type],
[Ticket Number],
[Contract],
[Details],
[Date],
[Client],
[Title],
round(sum([Hours]),2) as [Hours],
cast(sum([Price]) as money) as [Price]

from 
(
select
'Labor - Reviewed' as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where fcontractid=chid) AS [Contract], 
  null as [Details],
  dateoccured as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
  isnull(ActionChargeHours, 0) as [Hours],
  isnull(ActionChargeHours, 0)*(
        CASE 
            WHEN actioncode + 1 IN (
                    SELECT crchargeid
                    FROM chargerate
                    )
                AND (
                    SELECT areaint
                    FROM faults
                    WHERE faults.faultid = actions.faultid and fdeleted=0
                    ) = (
                    SELECT crarea
                    FROM chargerate
                    WHERE crarea = (
                            SELECT areaint
                            FROM faults
                            WHERE faults.faultid = actions.faultid and fdeleted=0
                            )
                        AND crchargeid = actioncode + 1
                    )
                THEN (
                        SELECT TOP 1 crrate
                        FROM chargerate
                        WHERE (crchargeid - 1) = actioncode
                            AND crstartdate < whe_
                            AND crarea = (
                                SELECT areaint
                                FROM faults
                                WHERE actions.faultid = faults.faultid and fdeleted=0
                                )
                        ORDER BY crstartdate DESC
                        )
            ELSE (
                    SELECT TOP 1 crrate
                    FROM chargerate
                    WHERE (crchargeid - 1) = actioncode
                        AND crstartdate < whe_
                        AND crarea = 0
                    ORDER BY crstartdate DESC
                    )
            END) as [Price]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
  join actions on actions.faultid = faults.faultid 
  left join area on aarea = areaint 
where 

RTIsOpportunity = 0 and RTIsProject=0 and fdeleted=0 and adontinvoice <> 1 
  and isnull((select fvalue7 from lookup where fid = 17 and fcode =(actioncode + 1)), '0') <> '1'
  and ActIsBillable <> 0 and ActIsReadyForProcessing <> 0
  and (
    ActProcessedDate < 4 
    or ActProcessedDate is null
  ) 
  and whe_ between @startdate and @enddate

  and actionchargehours>0
  and ActReviewed='True')labor

  group by 
[Type],
[Ticket Number],
[Contract],
[Details],
[Date],
[Client],
[Title]
  

  UNION ALL


  SELECT
'Labor - Unreviewed' as [Type],
  faults.faultid AS [Ticket Number], 
  (select CHcontractRef from contractheader where fcontractid=chid) AS [Contract], 
  (
        SELECT fvalue
        FROM lookup
        WHERE fid = 17
            AND fcode = (actioncode + 1)
        )
        + ' - ' +
        (CASE 
        WHEN actioncode + 1 IN (
                SELECT crchargeid
                FROM chargerate
                )
            AND (
                SELECT areaint
                FROM faults
                WHERE faults.faultid = actions.faultid and fdeleted=0
                ) = (
                SELECT crarea
                FROM chargerate
                WHERE crarea = (
                        SELECT areaint
                        FROM faults
                        WHERE faults.faultid = actions.faultid and fdeleted=0
                        )
                    AND crchargeid = actioncode + 1
                )
            THEN 'Overriding Rate'
        ELSE 'Global'
        END),
  whe_ as [Date],
  aareadesc as [Client], 
  symptom as [Title], 
  round(isnull(ActionChargeHours, 0),2) as [Hours],
  cast(isnull(ActionChargeHours, 0)*(
        CASE 
            WHEN actioncode + 1 IN (
                    SELECT crchargeid
                    FROM chargerate
                    )
                AND (
                    SELECT areaint
                    FROM faults
                    WHERE faults.faultid = actions.faultid and fdeleted=0
                    ) = (
                    SELECT crarea
                    FROM chargerate
                    WHERE crarea = (
                            SELECT areaint
                            FROM faults
                            WHERE faults.faultid = actions.faultid and fdeleted=0
                            )
                        AND crchargeid = actioncode + 1
                    )
                THEN (
                        SELECT TOP 1 crrate
                        FROM chargerate
                        WHERE (crchargeid - 1) = actioncode
                            AND crstartdate < whe_
                            AND crarea = (
                                SELECT areaint
                                FROM faults
                                WHERE actions.faultid = faults.faultid and fdeleted=0
                                )
                        ORDER BY crstartdate DESC
                        )
            ELSE (
                    SELECT TOP 1 crrate
                    FROM chargerate
                    WHERE (crchargeid - 1) = actioncode
                        AND crstartdate < whe_
                        AND crarea = 0
                    ORDER BY crstartdate DESC
                    )
            END) as money) as [Price]
FROM 
  faults 
  left join requesttype on requesttypenew = rtid 
  join actions on actions.faultid = faults.faultid 
  left join area on aarea = areaint 
where 

RTIsOpportunity=0 and RTIsProject=0 and fdeleted=0 and adontinvoice <> 1 
  and isnull((select fvalue7 from lookup where fid = 17 and fcode =(actioncode + 1)), '0') <> '1'
  and ActIsBillable <> 0 and ActIsReadyForProcessing <> 0
  and (
    ActProcessedDate < 4 
    or ActProcessedDate is null
  ) 
  and whe_ between @startdate and @enddate

  and actionchargehours>0
  and ActReviewed='False'


UNION ALL

Select
[Type],
[Ticket Number],
[Contract],
'Mileage: ' + cast(sum([Details]) as nvarchar) as [Details],
[Date],
[Client],
[Title],
[Hours],
cast(sum([Price]) as money) as [Price]


from 

(

Select
'Distance Travelled - Reviewed' as [Type],
actions.faultid as [Ticket Number],
(select CHcontractRef from contractheader where fcontractid=chid) as [Contract],
actions.mileage as [Details],
dateoccured as [Date],
aareadesc as [Client],
symptom as [Title],
null as [Hours],
cast(actions.mileage * 
(Select top 1 crrate from chargerate where ATravelChargeRate=CRchargeid order by CRstartdate desc)
as money) as [Price]



from actions 
join faults on faults.faultid=actions.faultid
join area on aarea=areaint
where actions.mileage>0 and actionmileageinvoicenumber is null and ActIsBillable='True' and ATravelChargeRate>0
and ActReviewed='True' and adontinvoice <> 1 and fdeleted=0 and whe_ between @startdate and @enddate

)travel

Group by 
[Type],
[Ticket Number],
[Contract],
[Date],
[Client],
[Hours],
[Title]


UNION ALL

Select
'Distance Travelled - Unreviewed' as [Type],
actions.faultid as [Ticket],
(select CHcontractRef from contractheader where fcontractid=chid) as [Contract],
'Mileage: ' + cast(actions.mileage as nvarchar) as [Details],
whe_ as [Date],
aareadesc as [Client],
symptom as [Title],
null as [Hours],
cast(actions.mileage * 
(Select top 1 crrate from chargerate where ATravelChargeRate=CRchargeid order by CRstartdate desc)
as money) as [Price]



from actions 
join faults on faults.faultid=actions.faultid
join area on aarea=areaint
where actions.mileage>0 and actionmileageinvoicenumber is null and ActIsBillable='True' and ATravelChargeRate>0
and ActReviewed='False' and adontinvoice <> 1 and fdeleted=0 and whe_ between @startdate and @enddate
