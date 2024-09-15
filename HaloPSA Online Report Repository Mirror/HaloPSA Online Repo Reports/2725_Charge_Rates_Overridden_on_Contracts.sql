SELECT
	  (SELECT fvalue FROM lookup WHERE fid = 17 AND fcode = CRchargeid) as 'Charge Type'
	, aareadesc as 'Client'
	, CHcontractRef as 'Contract Ref'
	, CRrate as 'Rate'
	, CRMinimum as 'Minimum Mins'
	, CRIncrement as 'Incrememnts'
	, CHOutOfHoursMultiplier as 'OOH Multiplier'
	, CRHolidayMultiplier as 'Holiday Multiplier'
FROM CHARGERATE
JOIN area ON crarea = aarea
JOIN CONTRACTHEADER on chid = crcontractid
