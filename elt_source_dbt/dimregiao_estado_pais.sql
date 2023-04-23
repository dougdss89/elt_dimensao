-- dimestadoregiao

-- analisar a dimens�o cliente e se ela possui algum campo que se ligue com as dimens�es de territ�rio
use AdventureWorks2019;
go

select
	psp.TerritoryID as countryid,
	psp.CountryRegionCode as countrycode,
	psp.StateProvinceID as stateid,
	psp.StateProvinceCode as statecode,
	psp.[name] as statename
from Person.StateProvince as psp


