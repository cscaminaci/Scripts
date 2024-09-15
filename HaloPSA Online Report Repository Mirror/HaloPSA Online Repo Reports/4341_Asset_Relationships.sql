SELECT
    *
FROM
    (
        SELECT

            gdesc AS [Group],
            tdesc AS [Type],
            dinvno AS [Name],
            did AS [Asset ID],
            bowner.uusername AS [Business Owner],
            towner.uusername AS [Technical Owner],
            fvalue AS [Status],
            yname,
            idata,
        STUFF((SELECT '', ', ' + CAST(a.dinvno AS VARCHAR(100)) + ' (' + fvalue + ')' [text()]
         FROM devicechild join device a on a.did=dccid join lookup on fid=66 and dcrelationship=fcode
         WHERE dcid=device.did
         FOR xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 1, '') as [Downstream Relationships],
         STUFF((SELECT '', ', ' + CAST(a.dinvno AS VARCHAR(100)) + ' (' + fvalue + ')' [text()]
         FROM devicechild join device a on a.did=dcid join lookup on fid=66 and dcrelationship=fcode
         WHERE dccid=device.did and dcissibling ='False'
         FOR xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 1, '') as [Upsteam Relationships],
        STUFF((SELECT '', ', ' + CAST(a.dinvno AS VARCHAR(100)) + ' (' + fvalue + ')' [text()]
         FROM devicechild join device a on a.did=dcid join lookup on fid=66 and dcrelationship=fcode
         WHERE dccid=device.did and dcissibling='True'
         FOR xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 1, '') as [Other Relationships],
        STUFF((SELECT '', ', ' + CAST(stdesc AS VARCHAR(100)) [text()]
         FROM servsite join SERVICEDEVICE on SDSTid=stid
         where SDDid=did
         FOR xml path(''), type).value('.', 'NVARCHAR(MAX)'), 1, 1, '') as [Related Services]
        FROM
            device
            JOIN xtype ON ttypenum = dtype
            JOIN site ON ssitenum = dsite
            JOIN area ON aarea = sarea
            JOIN generic ON ggeneric = tgeneric
            LEFT JOIN users bowner ON bowner.uid = dbusiness_owner_id
            LEFT JOIN users towner ON towner.uid = dtechnical_owner_id
            JOIN lookup ON dstatus = fcode AND fid = 61
            JOIN info ON isite = dsite AND inum = ddevnum
            JOIN typeinfo ON xnum = dtype AND iseq = xseq
            JOIN field ON ykind LIKE 'T' AND yseq = xfieldnos
    ) d
