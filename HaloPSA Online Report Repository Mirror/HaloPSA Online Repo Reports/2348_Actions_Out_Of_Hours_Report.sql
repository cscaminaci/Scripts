SELECT uname AS 'Technician'
	,aareadesc AS 'Company Name'
	,sdesc AS 'Site Name'
	,actions.faultid AS 'Ticket ID'
	,left(dateadd(hour, 0, whe_), 11) AS 'Worked Date'
	,whe_ as [Action Date]
	,(timetaken + timetakenadjusted) AS 'Hours'
	,(
		SELECT fvalue
		FROM lookup
		WHERE fid = 17
			AND fcode = actioncode + 1
		) AS [Charge Type]
	,note AS [Note]
	,(
		SELECT tstatusdesc
		FROM tstatus
		WHERE STATUS = tstatus
		) AS [Status]
	,dateadd(hour, 0, ActionArrivalDate) AS [Start Time]
	,dateadd(hour, 0, ActionCompletionDate) AS [End Time]
FROM faults
	,site
	,area
	,actions
	,uname
	,workdays
WHERE ssitenum = sitenumber
	AND aarea = sarea
	AND who = uname
	AND actions.faultid = faults.faultid
	AND uworkdayid = wdid
	AND (
		CASE 
			WHEN walldayssame = 1
				THEN (
						CASE 
							WHEN (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 1
									AND Wincsunday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 2
									AND Wincmonday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 3
									AND Winctuesday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 4
									AND Wincwednesday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 5
									AND Wincthursday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 6
									AND Wincfriday = 1
									)
								OR (
									datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 7
									AND Wincsaturday = 1
									)
								THEN (
										CASE 
											WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend)
												THEN 1
											WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart)
												THEN 1
											WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend)
												AND datepart(n, dateadd(hour, 0,  ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend)
												THEN 1
											WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart)
												AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart)
												THEN 1
											ELSE 0
											END
										)
							ELSE 1
							END
						)
			ELSE (
					(
						CASE 
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 1
								THEN (
										CASE 
											WHEN Wincsunday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend7)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart7)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend7)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend7)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart7)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart7)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincsunday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 2
								THEN (
										CASE 
											WHEN Wincmonday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend1)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart1)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend1)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend1)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart1)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart1)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincmonday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 3
								THEN (
										CASE 
											WHEN Winctuesday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, Wend2)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart2)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, Wend2)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, Wend2)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart2)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart2)
																THEN 1
															ELSE 0
															END
														)
											WHEN Winctuesday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 4
								THEN (
										CASE 
											WHEN Wincwednesday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend3)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart3)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend3)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend3)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart3)
																AND datepart(n, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart3)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincwednesday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 5
								THEN (
										CASE 
											WHEN Wincthursday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3) AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend4)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0,ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3) AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart4)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend4)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend4)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart4)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart4)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincthursday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 6
								THEN (
										CASE 
											WHEN Wincfriday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend5)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart5)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend5)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend5)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart5)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart5)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincfriday = 0
												THEN 1
											ELSE 0
											END
										)
							WHEN datepart(dw, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = 7
								THEN (
										CASE 
											WHEN Wincsaturday = 1
												THEN (
														CASE 
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(hh, wend6)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(hh, wstart6)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wend6)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) > datepart(n, wend6)
																THEN 1
															WHEN datepart(hh, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) = datepart(hh, wstart6)
																AND datepart(n, dateadd(hour, 0, ActionArrivalDate AT TIME ZONE 'UTC'  AT TIME ZONE (select rtimezone from control3))) < datepart(n, wstart6)
																THEN 1
															ELSE 0
															END
														)
											WHEN Wincsaturday = 0
												THEN 1
											ELSE 0
											END
										)
							ELSE 0
							END
						)
					)
			END
		) = 1
	AND fdeleted = 0
	AND fmergedintofaultid = 0

