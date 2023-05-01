select distinct
    sst.territoryid,
    sst.[name],
    sst.[group],
    sst.countryregioncode
from sales.salesterritory as sst
inner join
    person.countryregion as pcr
on pcr.countryregioncode = sst.countryregioncode
left join
    person.stateprovince as psp
on psp.countryregioncode = pcr.countryregioncode