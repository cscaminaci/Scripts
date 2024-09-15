select 
aareadesc as [Client],
ATaxable as [Is Taxable?],
case when ATaxable='False' then null when ASLAtaxcode=-2 then 'Use Item Tax' else (select taxdescription from tax where ASLAtaxcode=taxid) end as [Item Tax],
case when ATaxable='False' then null when ANONSLAtaxcode=-2 then 'Use Item Tax' else (select taxdescription from tax where ANONSLAtaxcode=taxid) end as [Labor Tax],
case when ATaxable='False' then null when AContractTaxCode=-2 then 'Use Item Tax' else (select taxdescription from tax where AContractTaxCode=taxid) end as [Contract Tax],
case when ATaxable='False' then null when aprepaytaxcode=-2 then 'Use Item Tax' else (select taxdescription from tax where aprepaytaxcode=taxid) end as [Pre-pay Tax]

from area
