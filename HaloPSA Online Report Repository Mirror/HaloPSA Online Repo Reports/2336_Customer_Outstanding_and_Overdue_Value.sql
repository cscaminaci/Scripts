SELECT aareadesc AS [Client]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
		) AS [Outstanding Value]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
			AND IHDue_Date < getdate()
		) AS [Outstanding Overdue Value]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
			AND IHDue_Date > getdate() - 30
			AND IHDue_Date < getdate()
		) AS [0-30 Days Overdue]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
			AND IHDue_Date > getdate() - 60
			AND IHDue_Date < getdate() - 30
		) AS [30-60 Days Overdue]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
			AND IHDue_Date > getdate() - 90
			AND IHDue_Date < getdate() - 60
		) AS [60-90 Days Overdue]
	,(
		SELECT sum(IDNet_Amount)
		FROM invoiceheader
		JOIN invoicedetail ON idihid = ihid
		WHERE ihaarea = aarea
			AND ihid > 0
			AND (
				ihdatepaid IS NULL
				OR ihdatepaid < 5
				)
			AND IHDue_Date < getdate() - 90
		) AS [90+ Days Overdue]
FROM area
where (select count(*) from invoiceheader where ihaarea = aarea
	AND ihid > 0
	AND (
		ihdatepaid IS NULL
		OR ihdatepaid < 5
		))>0
