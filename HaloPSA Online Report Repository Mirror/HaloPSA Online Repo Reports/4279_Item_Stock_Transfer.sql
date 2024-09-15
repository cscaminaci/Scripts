SELECT
    iid as [Item ID],
    idesc AS [Item Description],
    itemstockhistory.ISHlocation as [Site ID],
    sdesc AS [Site Location],
    ISHquantityIn as [Quantity],
    IScost as [Cost],
    ISHreason AS [Stock Detail],
    stbname as [Stock Bin],
    ISHdate AS [Date]
FROM 
    itemstockhistory
LEFT JOIN 
    site ON ssitenum = ISHlocation
LEFT JOIN 
    item ON item.iid = itemstockhistory.ISHiid
LEFT JOIN 
    itemstock on ISid = ISHitemStockId
LEFT JOIN
    stockbin ON  stbid = ishstbid
