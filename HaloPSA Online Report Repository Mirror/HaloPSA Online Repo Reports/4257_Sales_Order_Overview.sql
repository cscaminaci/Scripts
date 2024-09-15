SELECT
    OHid as [Sales Order ID],
    OHFaultid as [Ticket ID],
    (SELECT fvalue FROM lookup WHERE fid=34 and fcode=OHUserstatus) as [Status],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, [Price] * OLorderqty, 0)) as Money)) as [Recurring Price],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, [Cost] * OLorderqty, 0)) as Money)) as [Recurring Cost],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, ([Price]-[Cost]) * OLorderqty, 0)) as Money)) as [Recurring Profit],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, [Price] * OLorderqty, 0)) as Money)) as [One-Off Price],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, [Cost] * OLorderqty, 0)) as Money)) as [One-Off Cost],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, ([Price]-[Cost]) * OLorderqty, 0)) as Money)) as [One-Off Profit],
    OHorderdate as [Date],
    OHusername as [End User],
    (SELECT UName FROM UName WHERE UNUM=ohcreatedby) as [Agent Created],
    (SELECT UName FROM UName WHERE UNUM=ohassignedunum) as [Agent Assigned]
FROM
    (SELECT
        OLSellingPrice /
        CASE
        WHEN OLbillingperiod = 1 THEN 0.25
        WHEN OLbillingperiod = 2 THEN 1
        WHEN OLbillingperiod = 3 THEN 12
        WHEN OLbillingperiod = 4 THEN 3
        WHEN OLbillingperiod = 5 THEN 6
        WHEN OLbillingperiod = 6 THEN 60
        WHEN OLbillingperiod = 7 THEN 36
        WHEN OLbillingperiod = 8 THEN 24
        WHEN OLbillingperiod = 9 THEN 48
        ELSE 1 END
        as [Price],
        OLCostPrice /
        CASE
        WHEN OLbillingperiod = 1 THEN 0.25
        WHEN OLbillingperiod = 2 THEN 1
        WHEN OLbillingperiod = 3 THEN 12
        WHEN OLbillingperiod = 4 THEN 3
        WHEN OLbillingperiod = 5 THEN 6
        WHEN OLbillingperiod = 6 THEN 60
        WHEN OLbillingperiod = 7 THEN 36
        WHEN OLbillingperiod = 8 THEN 24
        WHEN OLbillingperiod = 9 THEN 48
        ELSE 1 END
        as [Cost],
        *
    FROM
        ORDERHEAD
        JOIN orderline on ohid=olid
        JOIN item on OLitem=iid
    )a
GROUP BY
    OHid,
    OHfaultID,
    OHUserstatus,
    OHorderdate,
    OHusername,
    ohcreatedby,
    ohassignedunum
