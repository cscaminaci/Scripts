SELECT
    Date_ID,
    (SELECT COUNT(*) FROM Faults WHERE DateOccured BETWEEN First_Day_Of_Month AND Last_Day_Of_Month and fdeleted=0 and fmergedintofaultid=0) AS [Opened],
    (SELECT COUNT(*) FROM Faults WHERE DateCleared BETWEEN First_Day_Of_Month AND Last_Day_Of_Month and fdeleted=0 and fmergedintofaultid=0) AS [Closed]
FROM
    Calendar
WHERE
    Date_ID BETWEEN @startdate AND @enddate
    AND Date_ID = First_Day_Of_Month
