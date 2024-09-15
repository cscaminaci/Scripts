select
	  cdcategoryname as [Cateogry]
	, (select count(faultid) from faults where category2=cdcategoryname and fdeleted=0
				and convert(nvarchar(7), datecleared, 126) = convert(nvarchar(7), getdate(), 126)) as [Tickets Closed This Month]
	, (select count(faultid) from faults where category2=cdcategoryname and fdeleted=0
				and convert(nvarchar(7), dateoccured, 126) = convert(nvarchar(7), getdate(), 126)) as [Tickets Logged This Month]
	, (select count(faultid) from faults where category2=cdcategoryname and fdeleted=0
				AND dateoccured < DATEADD(MM, datediff(mm,0,getdate()),0)
				AND (datecleared >= DATEADD(MM, datediff(mm,0,getdate()),0)
				OR status != 9)) as [Open Tickets at Start of Month]
	, (select count(faultid) from faults where category2=cdcategoryname and fdeleted=0
				AND dateoccured < DATEADD(mm,1,DATEADD(MM, datediff(mm,0,getdate()),0))
				AND (datecleared >= DATEADD(mm,1,DATEADD(MM, datediff(mm,0,getdate()),0))
				OR status != 9)) as [Open Tickets at End of Month]
from categorydetail
