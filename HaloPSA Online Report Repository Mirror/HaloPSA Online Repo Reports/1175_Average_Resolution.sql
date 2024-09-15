select isnull(nullif(round( AVG(elapsedhrs),2),0),0) as 'AverageFixTimeLast7DaysHours'from Faults where datecleared> GETDATE()-7 and FexcludefromSLA = 0 and fdeleted=0
