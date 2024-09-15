select 

Table_name as [Table Name],
Column_name as [Column Name],
Data_type as [Data Type],
Character_maximum_length as [Max Characters],
Is_nullable as [Can be Null?] 

from information_schema.columns
