select
	st.businessentityid as storeid,
	sc.PersonID,
	pp.businessentityid,
	sc.CustomerID as buyerid,
	sc.AccountNumber,
	st.[Name] as storename,
	pp.FirstName,
    pp.LastName,
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
	SalesPersonID, 
	sst.territoryid,
	[group] continentname,
	sst.[name] as regionname,
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
sc.TerritoryID = sst.TerritoryID