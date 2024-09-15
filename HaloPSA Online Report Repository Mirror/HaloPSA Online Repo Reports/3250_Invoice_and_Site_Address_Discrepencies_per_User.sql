SELECT

    ssitenum AS [Site Number],
    sdesc AS [Site Desc],
    [-1] AS [Invoice Address],
    [-2] AS [Site Address]

FROM (




    SELECT

        ssitenum,

        sdesc,

        astype,

        ASLine1 + CHAR(10) + ASLine2 + CHAR(10) + ASLine3 + CHAR(10) + ASLine4 + CHAR(10) + ASLine5 AS addressline

    FROM site




    JOIN ADDRESSSTORE ON ssitenum = ASSiteID

   

) src




PIVOT(

    MAX([addressline]) FOR astype IN ([-2], [-1])

) pvt




WHERE

    pvt.[-1] <> pvt.[-2]
