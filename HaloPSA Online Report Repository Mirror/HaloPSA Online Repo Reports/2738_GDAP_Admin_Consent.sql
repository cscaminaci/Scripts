SELECT aatazuretenantname             AS [Name],
       'https://login.microsoftonline.com/'
       + aatazuretenantid
       + '/adminConsent?client_id='
       + (SELECT acapplicationid
          FROM   azureadconnection
          WHERE  acid = aatdetailsid) AS [Admin Consent]
FROM   areaazuretenant 
