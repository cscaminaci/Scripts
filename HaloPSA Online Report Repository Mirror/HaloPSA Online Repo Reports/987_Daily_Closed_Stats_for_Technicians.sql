--DYNAMIC
Declare @startofweek nvarchar(10)
set @startofweek = (select convert(nvarchar(10),dateadd(wk, datediff(wk, 0, getdate()), 0), 120))
select uname
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared >=
			 @startofweek
			  and faults.datecleared -1 < 
             @startofweek) as Monday
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -1>=
			 @startofweek
			  and faults.datecleared -2 < 
             @startofweek) as Tuesday
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -2>=
			 @startofweek
			  and faults.datecleared -3 < 
             @startofweek) as Wednesday
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -3>=
			 @startofweek
			  and faults.datecleared -4 < 
             @startofweek) as Thursday			 
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -4>=
			 @startofweek
			  and faults.datecleared -5 < 
             @startofweek) as Friday			
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -5>=
			 @startofweek
			  and faults.datecleared -6 < 
             @startofweek) as Saturday
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared -6>=
			 @startofweek
			  and faults.datecleared -7 < 
             @startofweek) as Sunday
, (select count(faultid) from faults where uname.unum=faults.clearwhoint and
             faults.datecleared>=
			 @startofweek
			  and faults.datecleared -7 < 
             @startofweek) as Total			
			from uname where unum>1
