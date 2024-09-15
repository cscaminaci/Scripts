SELECT 
   aareadesc AS 'Client',
    sdesc AS 'Site',
    siteemaildomain AS 'Email_Domain'
FROM 
    site
    join area on aarea=sarea
WHERE     (siteemaildomain IS NULL OR siteemaildomain = '') 
and aisinactive=0
