SELECT
    *,
    ISNULL([Jan], 0) + ISNULL([Feb], 0) + ISNULL([Mar], 0) + ISNULL([Apr], 0) + ISNULL([May], 0) + ISNULL([Jun], 0) + ISNULL([Jul], 0) + ISNULL([Aug], 0) + ISNULL([Sep], 0) + ISNULL([Oct], 0) + ISNULL([Nov], 0) + ISNULL([Dec], 0) AS [Grand Total]
FROM
    (
        SELECT
            [Client],
            [Contract],
            [Recurring Invoice Number],
            CAST(SUM([IDNet_Amount]) AS MONEY) AS [Net Amount],
            [Period],
            [Next Invoice Creation],
            [Start Date],
            [End Date],
            FORMAT(Date_ID, 'MMM') AS [Month]
        FROM
            (
                SELECT
                    AAreaDesc AS [Client],
                    CHContractRef AS [Contract],
                    IHID AS [Recurring Invoice Number],
                    IDNet_Amount,
                    IDTax_Amount,
                    CASE StdPeriod
                        WHEN 1 THEN 'Weekly'
                        WHEN 2 THEN 'Monthly'
                        WHEN 4 THEN 'Quarterly'
                        WHEN 5 THEN '6-Monthly'
                        WHEN 3 THEN 'Yearly'
                        WHEN 8 THEN '2 Yearly'
                    END AS [Period],
                    STDNextCreationDate AS [Next Invoice Creation],
                    STDStartDate AS [Start Date],
                    STDEndDate AS [End Date]
                FROM
                    InvoiceHeader
                    LEFT JOIN ContractHeader ON IHCHID = CHID
                    INNER JOIN InvoiceDetail ON IDIHID = IHID
                    INNER JOIN StdRequest ON StdInvoiceID = IHID
                    INNER JOIN Area ON IHAArea = AArea
                WHERE
                    IHID < 0
                    AND CHStatus = 3
            ) InnerQ
            OUTER APPLY (
                SELECT
                    DATEPART(DAY, [Start Date]) AS [StartDay],
                    DATEPART(MONTH, [Start Date]) AS [StartMonth]
            ) Utility
            LEFT JOIN Calendar ON Date_ID BETWEEN [Start Date] AND [End Date] /*AND Date_ID >= GETDATE()*/ AND
                (
                    ([Period] = 'Weekly' AND DATEDIFF(DAY, [Start Date], Date_ID) % 7 = 0) OR
                    ([Period] = 'Monthly' AND (StartDay = Date_Day) OR (EOMONTH(Date_ID) = Date_ID AND StartDay > Date_Day)) OR
                    ([Period] = 'Quarterly' AND (StartDay = Date_Day) OR (EOMONTH(Date_ID) = Date_ID AND StartDay > Date_Day) AND DATEDIFF(MONTH, [Start Date], Date_ID) % 3 = 0) OR
                    ([Period] = '6-Monthly' AND (StartDay = Date_Day) OR (EOMONTH(Date_ID) = Date_ID AND StartDay > Date_Day) AND DATEDIFF(MONTH, [Start Date], Date_ID) % 6 = 0) OR
                    ([Period] = 'Yearly' AND StartMonth = Date_Month) OR
                    ([Period] = '2 Yearly' AND StartMonth = Date_Month AND DATEDIFF(YEAR, [Start Date], Date_ID) % 2 = 0)
                )
            WHERE
                YEAR(Date_ID) = YEAR(GETDATE())
        GROUP BY
            [Client],
            [Contract],
            [Recurring Invoice Number],
            [Period],
            [Next Invoice Creation],
            [Start Date],
            [End Date],
            Date_ID,
            Month_NM
    ) Pvt
PIVOT
    (
        SUM([Net Amount]) FOR [Month] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
    ) Pvted
