--DYNAMIC SQL
select
aareadesc as [Client],
sdesc as [Site],
dinvno as [Asset Tag],
idata as [Key Field],
[1] as [Field 1],
[2] as [Field 2],
[3] as [Field 3],
[4] as [Field 4],
[5] as [Field 5],
[6] as [Field 6],
[7] as [Field 7],
[8] as [Field 8],
[9] as [Field 9],
[10] as [Field 10],
tdesc as [Asset Type],
sla as [SLA],
PriorityDesc as [Priority],
dwarrantyenddate as [Warranty End Date] from( 
        select * from (
        select 
        aareadesc
        ,b.sdesc
        ,did 
        ,dinvno
        ,(select idata from info where ikind = 'd' and  isite=dsite and inum=ddevnum and iseq=tlabelseqnos)  as [idata] 
        ,tdesc as [tdesc] 
        ,idata as [Value] 
        ,sldesc as [SLA] 
        ,pdesc as [PriorityDesc] 
        ,dwarrantyenddate 
        ,ROW_NUMBER() OVER (PARTITION BY did ORDER BY xsortseq,yname ASC)  as [Row] 
         from device join xtype on ttypenum=dtype 
        join typeinfo on ttypenum=xnum 
        join field on ykind='t' and yseq=xfieldnos 
        join info on ikind = 'd' and  isite=dsite and inum=ddevnum and iseq=xseq 
        join site on dsite=ssitenum 
        left join policy on pslaid = dslaid AND ppolicy = dseriousness 
        left join slahead on slid = dslaid 
        join site b on b.ssitenum=dsite
        join area on aarea=b.sarea
        where dinactive=0
        )bb 
        where [Row] in (1,2,3,4,5,6,7,8,9,10) 
        )src 
        PIVOT 
        ( 
        max(value) for row in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10]) 
        )pvt

        

