SELECT [Invoice Number]
	,[Item]
	,'£' + cast([CP] AS NVARCHAR(50)) AS [Cost Price]
	,'£' + cast([SPG] AS NVARCHAR(50)) AS [Sell Price Gross]
	,[Tax Rate]
	,'£' + cast([PPU] AS NVARCHAR(50)) AS [Profit per Unit]
	,[Quantity]
	,'£' + cast([SPG] * [Quantity] AS NVARCHAR(50)) AS [Total Gross]
	,'£' + cast(round(([PPU] - [CP]) * [Quantity], 2) AS NVARCHAR(50)) AS [Total Net]
FROM (
	SELECT idihid AS [Invoice Number]
		,IDItem_Code
		,IDItem_ShortDescription AS [Item]
		,(
			SELECT icostprice
			FROM item
			WHERE iditem_code = iid
			) AS [CP]
		,IDUnit_Price AS [SPG]
		,cast(IDTax_Rate AS VARCHAR(50)) + '%' AS [Tax Rate]
		,IDQty_Order AS [Quantity]
		,1 - IDTax_Rate / 100 AS [Tax]
		,Round(IDUnit_Price * (1 - IDTax_Rate / 100), 2) AS [PPU]
	FROM InvoiceDetail
	) a
WHERE ISNUMERIC(IDItem_Code) = 1

