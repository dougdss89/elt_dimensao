
select

	psp.TerritoryID as countryid,
	psp.CountryRegionCode as countrycode,
	psp.StateProvinceID as stateid,
	psp.StateProvinceCode as statecode,
	psp.[name] as statename

from Person.StateProvince as psp;

