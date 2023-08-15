
select 
	distinct
	countryregionkey,
	TerritoryID as countryregionid,
	[Group] as regionzone,
	CountryRegionCode as countrycode,

		case
			when CountryRegionCode = 'US' then 'United States'
			when CountryRegionCode = 'CA' then 'Canada'
			when CountryRegionCode = 'FR' then 'France'
			when CountryRegionCode = 'GB' then 'United Kingdom'
			when CountryRegionCode = 'AU' then 'Australia'
			when CountryRegionCode = 'DE' then 'Germany'
		else CountryRegionCode 
		end as 'countryname',

	[name] as countryregion,

	case
		when [name] = 'Northwest' then 'NW'
		when [name] = 'Northeast' then 'NE'
		when [name] = 'Southwest' then 'SW'
		when [name] = 'Southeast' then 'SE'
		else 'CNT'
	end as regioncode

from stg_dim.stgcountryregion