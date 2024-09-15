SELECT [Section]
                ,[First response met]
                ,[First response breach]
                ,cast(round(isnull(CAST([First response met] AS FLOAT) * 100 / nullif(cast([Tickets Opened] AS FLOAT), 0), 0), 2) AS NVARCHAR) + '%' AS [% Response Met]
                ,[Tickets Opened]
                ,[Resolution SLA Met]
                ,[Resolution SLA Breach]
                ,cast(round(isnull(CAST([Resolution SLA Met] AS FLOAT) * 100 / nullif(cast([Tickets Opened] AS FLOAT), 0), 0), 2) AS NVARCHAR) + '%' AS [% Resolution Met]
				,[Priority 1 Tickets]
				,[Priority 2 Tickets]
				,[Priority 3 Tickets]
				,[Priority 4 Tickets]
				,[Priority 5 Tickets]
FROM (


                SELECT SDSectionName AS [Section]
                                ,(
                                                SELECT count(slaresponsestate)
                                                FROM faults
                                                WHERE sdsectionname = sectio_
                                                                AND SLAresponseState = 'I'
                                                                AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [First response met]
                                ,(
                                                SELECT COUNT(slaresponsestate)
                                                FROM Faults
                                                WHERE SDSectionName = sectio_
                                                                AND SLAresponseState = 'O'
                                                                AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [First response breach]
                                ,(
                                                SELECT count(faultid)
                                                FROM Faults
                                                WHERE SDSectionName = sectio_
                                                                AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Tickets Opened]
                                ,(
                                                SELECT COUNT(faultid)
                                                FROM Faults
                                                WHERE SDSectionName = sectio_
                                                                AND Slastate = 'I'
                                                                AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Resolution SLA Met]
                                ,(
                                                SELECT COUNT(faultid)
                                                FROM Faults
                                                WHERE SDSectionName = sectio_
                                                                AND Slastate in ('X','O')
                                                                AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Resolution SLA Breach]
								,(
												Select count (faultid)
												from faults
												where SDsectionname=sectio_
																AND seriousness=1
																AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Priority 1 Tickets]
								,(
												Select count (Faultid)
												from faults where sdsectionname=sectio_
																AND seriousness=2
																AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Priority 2 Tickets]
								,(
												Select count (Faultid)
												from faults where sdsectionname=sectio_
																AND seriousness=3
																AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Priority 3 Tickets]

								,(
												Select count (Faultid)
												from faults where sdsectionname=sectio_
																AND seriousness=4
																AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Priority 4 Tickets]

								,(				Select count (Faultid)
												from faults where sdsectionname=sectio_
																AND seriousness=5
																AND dateoccured > @startdate
                                                                AND dateoccured < @enddate
                                                ) AS [Priority 5 Tickets]

                FROM SectionDetail
             
			 
			    ) a

