Select
	  TN as 'Technicians Name'
	, NAF as 'Number of Awesome Feedback'
	, cast(isnull(round((NAF/nullif(TF,0))*100,0),0) as varchar(50)) + '%' as 'Percentage of Awesome Feedback'
	, NGF as 'Number of Good Feedback'
	, cast(isnull(round((NGF/nullif(TF,0))*100,0),0) as varchar(50)) + '%' as 'Percentage of Good Feedback'
	, NOF as 'Number of OK Feedback'
	, cast(isnull(round((NOF/nullif(TF,0))*100,0),0) as varchar(50)) + '%' as 'Percentage of OK Feedback'
	, NBF as 'Number of Bad Feedback'
	, cast(isnull(round((NBF/nullif(TF,0))*100,0),0) as varchar(50)) + '%' as 'Percentage of Bad Feedback'
from (Select
			  uname as 'TN'
			, cast((select count(fbscore) from feedback join faults on assignedtoint=unum where fbfaultid=faultid and fbscore=1) as float) as 'NAF'
			, cast((select count(fbscore) from feedback join faults on assignedtoint=unum where fbfaultid=faultid and fbscore=2) as float) as 'NGF'
			, cast((select count(fbscore) from feedback join faults on assignedtoint=unum where fbfaultid=faultid and fbscore=3) as float) as 'NOF'
			, cast((select count(fbscore) from feedback join faults on assignedtoint=unum where fbfaultid=faultid and fbscore=4) as float) as 'NBF'
			, cast((select count(fbscore) from feedback join faults on assignedtoint=unum where fbfaultid=faultid) as float) as 'TF'
		from uname)a
