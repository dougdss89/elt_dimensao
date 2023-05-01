-- dimestadoregiao

-- analisar a dimensao cliente e se ela possui algum campo que se ligue com as dimensoes de territorio
-- essa dimensao eh constituida apenas dos territorios que possuem venda

select
	psp.TerritoryID,
	psp.CountryRegionCode,
	psp.StateProvinceID,
	psp.StateProvinceCode,
	psp.[name]
from Person.StateProvince as psp


