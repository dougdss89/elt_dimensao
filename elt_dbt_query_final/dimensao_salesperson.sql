with salesperson_etl as (

select 
	pp.BusinessEntityID as salespersonid,
	hre.LoginID,
	pp.FirstName,
	pp.LastName,
	case
		when hre.Gender = 'M' then 'Male'
		when hre.Gender = 'F' then 'Female'
	end as Gender,
	(DATEDIFF(YY, hre.BirthDate, GETDATE())) as age,
	hre.HireDate,
	(DATEDIFF(YY, hre.HireDate, GETDATE())) as yearsincompany,
	hrd.GroupName as division,
	hrd.[Name] as subdivision,
	hre.jobtitle,
	case
		when ssp.TerritoryID is null and sst.CountryRegionCode is null and hre.jobtitle like 'North American%' then 1
		when ssp.TerritoryID is null and sst.CountryRegionCode is null and hre.jobtitle like 'Pacific sales%' then  9
		when ssp.TerritoryID is null and sst.CountryRegionCode is null and hre.jobtitle like 'European Sales%' then 8
		else ssp.TerritoryID
	end as territoryid,
	case
		when ssp.TerritoryID is null and hre.JobTitle like 'North American%' then 'US'
		when ssp.TerritoryID is null and hre.JobTitle like 'European Sales%' then 'EU'
		when ssp.TerritoryID is null and hre.JobTitle like 'Pacific Sales%' then 'UA'
	else sst.CountryRegionCode
	end as countrycode,
	case
		when JobTitle like 'North american%' and sst.[name] is null then 'USA HQ'
		when JobTitle like 'Pacific Sales%' and sst.[name] is null then 'Sidney HQ'
		when JobTitle like 'European Sales%' and sst.[Name] is null then 'Berlim HQ'
	else sst.[name]
	end as salesregion,
	cast(hreph.Rate as numeric(5,2)) as salaryhour,
	hreph.PayFrequency,
	cast(hreph.RateChangeDate as date) as salarychangedt,
	case 
		when JobTitle like 'North American%' and CommissionPct = 0.00 then  0.05
		when JobTitle like 'Pacific Sales%' and CommissionPct = 0.00 then 0.04
		when JobTitle like 'European Sales%' and CommissionPct = 0.00 then 0.04
	else ssp.commissionpct
	end as commission,
	case
		when JobTitle like 'North American%' and ssp.salesquota is null then cast((select max(SalesQuota) *.70 + max(salesquota) 
																					from Sales.SalesPerson) as numeric(9,2))
		when JobTitle like 'European Sales%' and ssp.SalesQuota is null then cast((select max(salesquota) *.65 + max(salesquota) 
																					from sales.SalesPerson) as numeric(9,2))
		when JobTitle like 'Pacific Sales%' and ssp.SalesQuota is null then cast(( select max(salesquota) *.55 + max(SalesQuota) 
																					from Sales.SalesPerson) as numeric(9,2))
	else ssp.SalesQuota
	end as quota,
	ssp.bonus,
	case
		when hre.SalariedFlag = 1 then 'Yes'
		else 'No'
	end as issalaried,
	case 
		when hre.CurrentFlag = 1 then 'Yes'
		else 'No'
	end as isactive,
	pp.Demographics
from Person.Person as pp
left join
	HumanResources.Employee as hre
on pp.BusinessEntityID = hre.BusinessEntityID
left join
	HumanResources.EmployeeDepartmentHistory as hredh
on hre.BusinessEntityID = hredh.BusinessEntityID
left join
	HumanResources.Department as hrd
on hredh.DepartmentID = hrd.DepartmentID
left join
	HumanResources.EmployeePayHistory as hreph
on hre.BusinessEntityID = hreph.BusinessEntityID
inner join
	Sales.SalesPerson as ssp
on hre.BusinessEntityID = ssp.BusinessEntityID
left join
	Sales.SalesTerritory as sst
on ssp.TerritoryID = sst.TerritoryID
),

salesperson_bonus as (

	select
		cast(salespersonid as smallint) as salespersonid,
		cast(loginid as nvarchar(40)) as loginid,
		cast(firstname as varchar(20)) as firstname,
		cast(lastname as varchar(40)) as lastname,
		cast(gender as varchar(10)) as gender,
		cast(age as tinyint) as age,
		cast(hiredate as date) as hiredate,
		cast(yearsincompany as smallint) as yearsincompany,
		cast(division as varchar(50)) as division,
		cast(subdivision as varchar(10)) as subdivision,
		cast(jobtitle as varchar(40)) jobtitle,
		cast(territoryid as tinyint) as territoryid,
		cast(countrycode as varchar(5)) as countrycode,
		cast(salesregion as varchar(20)) as salesregion,
		cast(salaryhour as numeric(5,2)) as salaryhour,
		cast(payfrequency as tinyint) as payfrequency,
		cast(salarychangedt as date) as salarychangedt,
		cast(commission as numeric(5,3)) as commission,
		cast(quota as numeric(12,2)) as quota,
		case
			when JobTitle like '%Manager' then cast((quota * commission) as numeric(12,2))
			when Bonus < 100.00 then (Bonus * 10)
		else bonus
		end as bonus,
		cast(issalaried as char(5)) as issalaried,
		cast(isactive as char(5)) as isactive
	from salesperson_etl),

salesperson_final as (
select
		cast(salespersonid as smallint) as salespersonid,
		cast(loginid as nvarchar(40)) as loginid,
		cast(firstname as varchar(20)) as firstname,
		cast(lastname as varchar(40)) as lastname,
		cast(gender as varchar(10)) as gender,
		cast(age as tinyint) as age,
		cast(hiredate as date) as hiredate,
		cast(yearsincompany as smallint) as yearsincompany,
		cast(division as varchar(50)) as division,
		cast(subdivision as varchar(10)) as subdivision,
		cast(jobtitle as varchar(40)) jobtitle,
		cast(territoryid as tinyint) as territoryid,
		cast(countrycode as varchar(5)) as countrycode,
		cast(salesregion as varchar(20)) as salesregion,
		cast(salaryhour as numeric(5,2)) as salaryhour,
		cast(payfrequency as tinyint) as payfrequency,
		cast(salarychangedt as date) as salarychangedt,
		cast(commission as numeric(5,3)) as commission,
		cast(quota as numeric(12,2)) as quota,
		cast(bonus as numeric(12,2)) as bonus,
		cast(issalaried as char(5)) as issalaried,
		cast(isactive as char(5)) as isactive
from salesperson_bonus)

select * from salesperson_final;
go