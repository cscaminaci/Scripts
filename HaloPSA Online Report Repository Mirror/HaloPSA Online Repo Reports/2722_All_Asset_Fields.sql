SELECT
    *
FROM
    (
        SELECT
            DID AS [Device ID],
            DInvNo AS [Asset Tag/ Name],
            UDUsername AS [Linked User],
            SDesc AS [Site],
            YName,
            IData
        FROM
            Device
            LEFT JOIN XType ON TTypeNum = DType
            LEFT JOIN TypeInfo ON TTypeNum = XNUm
            LEFT JOIN Field ON YKind = 'T' AND YSeq = XFieldNos
            LEFT JOIN Info ON IKind = 'D' AND ISite = DSite AND INum = DDevNum AND ISeq = XSeq
            LEFT JOIN UserDevice ON UDDevSite = DSite AND UDDevNum = DDevNum
            LEFT JOIN Users ON UDSite = USite AND UDUsername = UUsername
            LEFT JOIN Site ON SSiteNum = dsite
    ) Pvt
PIVOT
(
    MAX(IData) FOR YName IN
    (
        [Model],
        [RAM Memory],
        [OS Version],
        [Disc Size],
        [Processor],
        [Connect],
        [LastVulnScan],
        [driveFree],
        [driveSize],
        [IP address],
        [lastSystemBoot],
        [manufacturer],
        [Purchase Cost],
        [LastLoggedOnUser],
        [Date Purchased],
        [Retired Date],
        [PO Number],
        [Purchase Request],
        [Status],
        [Warranty],
        [Asset Type],
        [Supplier],
        [Disposal Reason],
        [Domain],
        [Serial Number],
        /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */  
        /* Put the exact name of the asset field in square brackets and it should search for the field and input the data.*/
        [IMEI Number]
    )
) Pivoted
