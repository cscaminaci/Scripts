SELECT
    iid as [Item ID],
    idesc AS [Item Name],
    idesc2 as [SKU],
    itemstockhistory.ISHlocation as [Site ID],
    aareadesc + ' - ' + sdesc AS [Stock Location],
    ISHquantityIn*-1 as [Quantity],
    cast(IScost as money) as [Cost],
    cast(OLSellingPrice as money) as [Price],
    ISHreason AS [Note],
    stbname as [Stock Bin],
    (select aareadesc + ' - ' + sdesc from site join area on aarea=sarea where ISHsite=ssitenum) as [Destination],
    ISHdate AS [Date]
FROM 
    itemstockhistory
LEFT JOIN 
    site ON ssitenum = ISHlocation
LEFT JOIN
    area on aarea=sarea
LEFT JOIN 
    item ON item.iid = itemstockhistory.ISHiid
LEFT JOIN 
    itemstock on ISid = ISHitemStockId
LEFT JOIN
    stockbin ON  stbid = ishstbid
LEFT JOIN
     orderline on ISHohid=OLid and OLitem=ISHiid


where ISHquantityIn<0
