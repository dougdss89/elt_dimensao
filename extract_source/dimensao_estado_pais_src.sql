-- dimestadoregiao

-- analisar a dimens�o cliente e se ela possui algum campo que se ligue com as dimens�es de territ�rio

select
	psp.TerritoryID,
	psp.CountryRegionCode,
	psp.StateProvinceID,
	psp.StateProvinceCode,
	psp.[name]
from Person.StateProvince as psp


