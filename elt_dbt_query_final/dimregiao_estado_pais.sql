
select
	provincekey as statekey,
	TerritoryID as countryid,
	CountryRegionCode as countrycode,
	StateProvinceID as stateid,
	StateProvinceCode as statecode,
	[name] as statename

from stg_dim.stgstateprovince

