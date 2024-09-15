select
(select uname from Uname where Unum=exunum) as Technician,
EXFaultid as Request_ID,
EXDescription as Description,
EXAmount as Amount,
(Select fvalue from lookup where fid = 35 and fcode = expense.extypelookup) as Type,
EXDateAdded as Date_Added,
EXDateReImbursed as Date_Reimbursed,
EXDateInvoiced as Date_Invoiced,
EXProof as Proof
from Expense 

