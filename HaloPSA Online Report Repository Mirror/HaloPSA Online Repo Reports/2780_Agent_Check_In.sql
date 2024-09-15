select 
 ACItimestamp as [Time Logged]
, (select fvalue from lookup where fid=78 and fcode=ACIstatus) as [Status]
, (select uname from uname where unum=ACIunum) as [Agent]

 from agentcheckin
