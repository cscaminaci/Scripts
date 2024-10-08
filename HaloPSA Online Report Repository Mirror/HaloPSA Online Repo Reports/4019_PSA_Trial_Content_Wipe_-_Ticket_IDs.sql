SELECT STRING_AGG(FaultID,', ') AS [Ticket IDs]
FROM(SELECT FaultID, FaultID%3 as agg1
FROM Faults WHERE FXRefTo IN (SELECT FaultID FROM Faults WHERE
FXRefTo IN (9,13,14,15,16,2137,2138,2139,2140,2145,2146,2155,2162,2163,2164,2165,2170,2171,2172,2173,2175,2176,2177,2178,2179,2180,2181,2184,2189,2190,2191,2193,2194,2196,2201,2202,2203,2242,2259,2279,2280,2293,2294,2296,2297,2358,2394,2500)
OR FXRefTo IN (SELECT FaultID FROM Faults WHERE FXRefTo IN (SELECT FaultID FROM Faults WHERE AreaInt IN (2,13,14,15,16,17,18)))))agg1
GROUP BY agg1

/*Children of children*/

UNION ALL

SELECT STRING_AGG(FaultID,', ') AS [Ticket IDs]
FROM(SELECT FaultID, FaultID%7as agg1
FROM Faults WHERE FXRefTo IN (9,13,14,15,16,2137,2138,2139,2140,2145,2146,2155,2162,2163,2164,2165,2170,2171,2172,2173,2175,2176,2177,2178,2179,2180,2181,2184,2189,2190,2191,2193,2194,2196,2201,2202,2203,2242,2259,2279,2280,2293,2294,2296,2297,2358,2394,2500)
OR FXRefTo IN (SELECT FaultID FROM Faults WHERE AreaInt IN (2,13,14,15,16,17,18)))agg1
GROUP BY agg1

/*Children*/

UNION ALL

SELECT STRING_AGG(FaultID,', ') AS [Ticket IDs]
FROM(SELECT FaultID, FaultID%11 as agg1
FROM Faults WHERE (FaultID IN (9,13,14,15,16,2137,2138,2139,2140,2145,2146,2155,2162,2163,2164,2165,2170,2171,2172,2173,2175,2176,2177,2178,2179,2180,2181,2184,2189,2190,2191,2193,2194,2196,2201,2202,2203,2242,2259,2279,2280,2293,2294,2296,2297,2358,2394,2500)
OR FaultID IN (SELECT FaultID FROM Faults WHERE AreaInt IN (2,13,14,15,16,17,18)))
AND (FXRefTo = 0 OR FXRefTo IS NULL))agg1
GROUP BY agg1

/*Parents*/
