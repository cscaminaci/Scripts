SELECT
    QHid as [Quote ID],
    QHPORef as [Reference],
    QHfaultID as [Ticket ID],
    (SELECT fvalue FROM lookup WHERE fid=39 and fcode=QHstatus) as [Status],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, [Price] * QDQuantity, 0)) as Money)) as [Recurring Price],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, [Cost] * QDQuantity, 0)) as Money)) as [Recurring Cost],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=1, ([Price]-[Cost]) * QDQuantity, 0)) as Money)) as [Recurring Profit],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, [Price] * QDQuantity, 0)) as Money)) as [One-Off Price],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, [Cost] * QDQuantity, 0)) as Money)) as [One-Off Cost],
    CONCAT('£', CAST(SUM(IIF(IIsRecurringItem=0, ([Price]-[Cost]) * QDQuantity, 0)) as Money)) as [One-Off Profit],
    QHDate as [Date],
    QHExpiryDate as [Expiry Date],
    (SELECT UUsername FROM Users WHERE uid=QHUserID) as [End User],
    (SELECT UName FROM UName WHERE UNUM=QHUnum) as [Agent Created],
    (SELECT UName FROM UName WHERE UNUM=QHAssignedUnum) as [Agent Assigned]
FROM 
    (SELECT
        QDPrice /
        CASE
        WHEN qdbillingperiod = 1 THEN 0.25
        WHEN qdbillingperiod = 2 THEN 1
        WHEN qdbillingperiod = 3 THEN 12
        WHEN qdbillingperiod = 4 THEN 3
        WHEN qdbillingperiod = 5 THEN 6
        WHEN qdbillingperiod = 6 THEN 60
        WHEN qdbillingperiod = 7 THEN 36
        WHEN qdbillingperiod = 8 THEN 24
        WHEN qdbillingperiod = 9 THEN 48
        ELSE 1 END
        as [Price],
        QDCostPrice /
        CASE
        WHEN qdbillingperiod = 1 THEN 0.25
        WHEN qdbillingperiod = 2 THEN 1
        WHEN qdbillingperiod = 3 THEN 12
        WHEN qdbillingperiod = 4 THEN 3
        WHEN qdbillingperiod = 5 THEN 6
        WHEN qdbillingperiod = 6 THEN 60
        WHEN qdbillingperiod = 7 THEN 36
        WHEN qdbillingperiod = 8 THEN 24
        WHEN qdbillingperiod = 9 THEN 48
        ELSE 1 END
        as [Cost],
        *
    FROM
        QUOTATIONHEADER
        JOIN QUOTATIONDETAIL on qhid=qdqhid
        JOIN item on qditemid=iid
    ) a
GROUP BY
    QHid,
    QHfaultID,
    QHstatus,
    QHPORef,
    QHDate,
    QHExpiryDate,
    QHUserID,
    QHUnum,
    QHAssignedUnum
