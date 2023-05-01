use AdventureWorks2019;
go

with xml_extract as (
select
	st.businessentityid as storeid,
	sc.PersonID as managerid,
	pp.businessentityid,
	sc.CustomerID buyerid,
	sc.AccountNumber as storeaccount,
	st.[Name] as storename,
	pp.FirstName +' '+ pp.LastName as managername,
	st.Demographics,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:AnnualSales)[1]','numeric(12,2)') AS AnnualSales,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:AnnualRevenue)[1]','numeric(12,2)') AS AnnualRevenue,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:BankName)[1]','varchar(50)') AS BankName,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:BusinessType)[1]','varchar(20)') AS BusinessType,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:YearOpened)[1]','smallint') AS YearOpened,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:Specialty)[1]','varchar(10)') AS Specialty,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:SquareFeet)[1]','numeric(9,2)') AS SquareFeet,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:Brands)[1]','varchar(5)') AS Brands,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:Internet)[1]','varchar(5)') AS Internet,
	st.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; (/ns:StoreSurvey/ns:NumberEmployees)[1]','smallint') AS NumberEmployees,
	SalesPersonID as salesrepresentant, 
	sst.territoryid,
	[group] as continent,
	case 
		when sst.CountryRegionCode = 'us' then 'United States'
		when sst.CountryRegionCode = 'au' then 'Australia'
		when sst.CountryRegionCode = 'de' then 'Gernamy'
		when sst.CountryRegionCode = 'ca' then 'Canada'
		when sst.CountryRegionCode = 'fr' then 'France'
		when sst.CountryRegionCode = 'gb' then 'United Kingdom'
	end as country,
	sst.[name] as countryregion,
	sst.CountryRegionCode
from Sales.Store st
left join
Sales.Customer as sc
on st.BusinessEntityID = sc.StoreID
left join
Person.Person as pp
on pp.BusinessEntityID = sc.PersonID
left join
Sales.SalesTerritory as sst
on
sc.TerritoryID = sst.TerritoryID),

store_elt as (
select distinct
	storeid,
	managerid,
	businessentityid,
	buyerid,
	storename,
	managername,
	salesrepresentant as salespersonid,
	yearopened,
	datediff(y, YearOpened, cast(year(getdate()) as smallint)) as yearsactive,
	businesstype,
	specialty,
	case 
		when brands = '4+' then 'Four or More'
		when brands = '2' then 'Two Brands'
		when brands = '1' then 'One Brand'
		when brands = '3' then 'Three brands'
		else 'Adv Works'
	end as brands,
	internet,
	case
		when AnnualSales > 0 then AnnualRevenue
		else AnnualSales
	end as annualsales,
	annualrevenue,
	case
		when annualrevenue <= 30000.00 then 'Local store'
		when annualrevenue > 30000.00 and annualrevenue < 80000.00 then 'Small store'
		when annualrevenue > 80000.00 and annualrevenue < 100000.00 then 'Medium store'
		when annualrevenue > 100000 and annualrevenue < 150000.00 then 'Large store'
		else 'Global company'
	end as storesize,
	numberemployees,
	xme.territoryid,
	continent,
	country,
	case
		when country not like 'United States' then 'Central'
	else countryregion
	end as countryregion
from xml_extract as xme)

select * from store_elt;
