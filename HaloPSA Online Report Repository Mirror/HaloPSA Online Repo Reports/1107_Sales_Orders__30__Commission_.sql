Select [Order Summary]
	,[Order Date]
	,'£' + convert(nvarchar,[Total Cost Price]) as [Total Cost Price]
	,'£' + convert(nvarchar,[Total Sales Price]) as [Total Sales Price]
	,[Agent]
	,'£' + convert(nvarchar,[Total Sales Price]-[Total Cost Price]) as [Profit]
	,'30%' as [Rate]
	,'£' + convert(nvarchar,round(convert(real,([Total Sales Price]-[Total Cost Price])*0.3),2)) as [Commission]
From(
SELECT ohsummary AS [Order Summary]
	,ohorderdate AS [Order Date]
	,(select sum(OLCostPrice*OLorderqty) from orderline where olid=ohid) as [Total Cost Price]
	,(select sum(olsellingprice*OLorderqty) from orderline where olid=ohid) as [Total Sales Price]
	,(SELECT uname from uname where unum =(select assignedtoint from faults where faultid=OHfaultid)) as [Agent]
FROM ORDERHEAD
where OHorderdate>@startdate and OHorderdate<@enddate
)d
