SELECT *
FROM (
    SELECT uname AS [Engineer]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Monday (Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Monday (Non Bill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Tueday (Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 1)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Tueday (Non Bill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                    AND who = uname
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Wednesday (Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 2)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Wednesday (Non Bill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Thursday (Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 3)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Thursday (Non Bill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 5)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 5)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Friday (Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 5)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) = convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 4)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 5)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Friday (Non Bill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(timetaken, 0)), 0) / 24
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Total(Hours)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) >= convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1))
                                            AND convert(DATE, hdate) < convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) >= convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1))
                                                AND convert(DATE, hdate) < convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Total(NonBill)]
        ,isnull(convert(NVARCHAR(10), datediff(hh, 0, dateadd(ss, 30, convert(DATETIME, (
                                SELECT isnull(sum(isnull(nonbilltime, 0) + isnull(timetaken, 0)) / 24, 0) + (
                                        SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                        FROM holidays
                                        WHERE (
                                                htechnicianid = unum
                                                OR htechnicianid = 0
                                                )
                                            AND convert(DATE, hdate) >= convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1))
                                            AND convert(DATE, hdate) < convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
                                        )
                                FROM actions
                                WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                    AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                    AND who = uname
                                    AND actions.faultid IN (
                                        SELECT faultid
                                        FROM faults
                                        WHERE requesttypenew <> 16
                                        )
                                ))))) + ':' + right('0' + convert(NVARCHAR(2), datediff(n, 0, dateadd(ss, 30, convert(DATETIME, (
                                    SELECT isnull(sum(isnull(nonbilltime, 0) + isnull(timetaken, 0)) / 24, 0) + (
                                            SELECT isnull(sum(isnull(hduration, 0)), 0) / 24
                                            FROM holidays
                                            WHERE (
                                                    htechnicianid = unum
                                                    OR htechnicianid = 0
                                                    )
                                                AND convert(DATE, hdate) >= convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1))
                                                AND convert(DATE, hdate) < convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
                                            )
                                    FROM actions
                                    WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                        AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                        AND who = uname
                                        AND actions.faultid IN (
                                            SELECT faultid
                                            FROM faults
                                            WHERE requesttypenew <> 16
                                            )
                                    )))) % 60), 2), '0:00') AS [Total(All)]
        ,isnull(convert(DECIMAL, (
                    (
                        SELECT sum(timetaken)
                        FROM actions
                        WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                            AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                            AND who = uname
                        ) / (
                        (
                            SELECT isnull(sum(isnull(nonbilltime, 0)), 0) + (
                                    SELECT sum(isnull(hduration, 0))
                                    FROM holidays
                                    WHERE htechnicianid = unum
                                        AND convert(DATE, hdate) >= convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1))
                                        AND convert(DATE, hdate) < convert(DATE, DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
                                    )
                            FROM actions
                            WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                AND who = uname
                            ) + (
                            SELECT sum(timetaken)
                            FROM actions
                            WHERE whe_ > DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), - 1)
                                AND whe_ < DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)
                                AND who = uname
                            )
                        ) * 100
                    )), 100) AS [Percentage Billable (%)]
    FROM uname
    ) a


