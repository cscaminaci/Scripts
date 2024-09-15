select  
(select aareadesc from Area where aarea=(select areaint from Faults where Faults.Faultid=ACTIONS.faultid)) as 'Client',
Faultid as 'Ticket Number',
convert(date,Whe_) as 'When',
actionprepayhours as 'Hours',
case      when actioncode+1 in (select crchargeid from chargerate) and (select areaint from faults where   faults.faultid=actions.faultid)=(select crarea from chargerate where crarea=(select areaint from faults where   faults.faultid=actions.faultid) and crchargeid=actioncode+1)   then (select crrate from chargerate where (crchargeid-1)=actioncode and crarea=(select areaint from faults where   actions.faultid=faults.faultid))  else (select crrate from chargerate where (crchargeid-1)=actioncode and crarea=0) end as [Charge Rate],

round(actionprepayhours * (case      when actioncode+1 in (select crchargeid from chargerate) and (select areaint from faults where   faults.faultid=actions.faultid)=(select crarea from chargerate where crarea=(select areaint from faults where   faults.faultid=actions.faultid) and crchargeid=actioncode+1)   then (select crrate from chargerate where (crchargeid-1)=actioncode and crarea=(select areaint from faults where   actions.faultid=faults.faultid))  else (select crrate from chargerate where (crchargeid-1)=actioncode and crarea=0) end), 2) as [Amount]

from actions where actionprepayhours<>0 and whe_ between @startdate and @enddate
