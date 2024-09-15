SELECT DISTINCT
        ORname as [Organisation]
      , TreeDesc as [Department]
      , SDSectionName as [Team]
      , uname as [Agent]
      , CASE 
	        WHEN usIsManager = 0 THEN '-'
            WHEN usIsManager = 1 THEN 'Yes'
        END as [Team Leader]
      , CASE 
	        WHEN UDmembershiplevel = 3 THEN 'Yes'
            ELSE '-'
        END as [Head of Department]
FROM unamesection
JOIN uname on Unum=USUnum
JOIN SECTIONDETAIL on USSdid = SdId
JOIN UnameDepartment on Unum=UDunum 
JOIN tree on UDdepartmentid=TreeId
JOIN ORGANISATION on TreeOrgid = Orid
WHERE 
        treetype=1 
	AND treeparentid=2

