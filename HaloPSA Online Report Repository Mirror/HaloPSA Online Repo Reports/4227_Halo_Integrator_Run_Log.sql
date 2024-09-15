select  
MSActualName [Integration]
, MSHaloIntegratorLastSync [Last Run Time]
, isnull(MSHaloIntegratorLastError, 'N/A') [Error]
, mshalointegratorenabled [Halo Integrator Enabled]

from modulesetup where mshalointegratorenabled='true'
and MSActualName not in ('Microsoft CSP', 'Azure Active Directory')

UNION 

select
ACName [Name]
, ACHaloIntegratorLastSync [Last Sync]
, isnull(ACHaloIntegratorLastError, 'N/A') [Last Error]
, achalointegratorenabled [Halo Integrator Enabled]

from azureadconnection
where achalointegratorenabled='true'

UNION

select
ncdname [Name]
, NCDLastSyncDate [Last Sync]
, isnull(NCDLastSyncError, 'N/A') [Last Error]
, NCDEnableIntegrator [Integrator Enabled]

from ncentraldetails
where NCDEnableIntegrator='true'

UNION

select 
IMDUrl [Name]
, IMDHaloIntegratorLastSync [Last Sync]
, isnull(IMDHaloIntegratorError, 'N/A') [Last Error]
, IMDHaloIntegrator [Integrator Enabled]

from ingrammicrodetails
where IMDHaloIntegrator='true'

UNION
select
sydname [Name]
, sydhalointegratorlastsync [Last Sync]
, isnull(sydhalointegratorerror, 'N/A') [Last Error]
, sydhalointegrator [Integrator Enabled]

from SynnexDetails
where sydhalointegrator='true'

UNION

select
soidname [Name]
, soidhalointegratorlastsync [Last sync]
, isnull(soidhalointegratorerror, 'N/A') [Last Error]
, soidhalointegrator [Integrator Enabled]

from streamoneiondetails
where soidhalointegrator='true'
