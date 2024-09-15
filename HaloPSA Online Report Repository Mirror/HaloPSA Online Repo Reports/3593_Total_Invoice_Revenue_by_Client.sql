SELECT 
'All Clients:' AS [Client],
ROUND(IIF(SUM(IDNet_Amount)<0,0,SUM(IDNet_Amount)),2) AS [Total Value]

FROM InvoiceHeader
JOIN InvoiceDetail ON IDIHID=IHID

WHERE IHID >= 0
AND IHDatePaid BETWEEN @StartDate AND @EndDate


UNION ALL


SELECT
IIF(IHName='','[Unknown]',IHName) AS [Client],
ROUND(IIF(SUM(IDNet_Amount)<0,0,SUM(IDNet_Amount)),2) AS [Total Value] /*Excluding freebies (I think...)*/


FROM InvoiceHeader
JOIN InvoiceDetail ON IDIHID=IHID

WHERE IHID >= 0
AND IHDatePaid BETWEEN @StartDate AND @EndDate

GROUP BY IHName
