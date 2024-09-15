select l1.fvalue[Country Code], l2.fvalue[Region Code], l2.fcode[Region Code ID] 
from lookup l1 join lookup l2 on l2.fvalue3=l1.fcode and l2.fid=77 where l1.fid=74
