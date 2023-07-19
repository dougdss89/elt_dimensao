
select 
	distinct
	sst.TerritoryID as countryregionid,
	sst.[Group] as regionzone,
	sst.CountryRegionCode as countrycode,
		case
			when sst.CountryRegionCode = 'US' then 'United States'
			when sst.CountryRegionCode = 'CA' then 'Canada'
			when sst.CountryRegionCode = 'FR' then 'France'
			when sst.CountryRegionCode = 'GB' then 'United Kingdom'
			when sst.CountryRegionCode = 'AU' then 'Australia'
			when sst.CountryRegionCode = 'DE' then 'Germany'
		else sst.CountryRegionCode 
		end as 'countryname',
	sst.[name] as countryregion,
	case
		when sst.[name] = 'Northwest' then 'NW'
		when sst.[name] = 'Northeast' then 'NE'
		when sst.[name] = 'Southwest' then 'SW'
		when sst.[name] = 'Southeast' then 'SE'
		else 'CNT'
	end as regioncode
from Sales.SalesTerritory as sst
inner join
	Person.CountryRegion as pcr
on sst.CountryRegionCode = pcr.CountryRegionCode
left join
	Person.StateProvince as psp
on pcr.CountryRegionCode = psp.CountryRegionCode;


--select * from Sales.SalesTerritory;