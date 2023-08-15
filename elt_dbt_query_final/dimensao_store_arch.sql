
with store_elt as (

	select
		storekey,
		storeid,
		personid as managerid,
		businessentityid,
		buyerid,
		storename,
		firstname +' ' + LastName as managername ,
		salespersonid as salesrepresentant,
		yearopened,
		datediff(y, YearOpened, cast(year(getdate()) as smallint)) as yearsactive,

		case 
			when Specialty = 'OS' then 'Online Store'
			when Specialty = 'BM' then 'Bike Market'
			else 'Bike Store'
		end as businesstype,
		
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
		territoryid,
		continentname,
		regionname,

		case
			when regionname not like 'United States' then 'Central'
		else CountryRegionCode
		end as countryregion

from stg_dim.stgstore)

select * from store_elt
where managerid is null and businessentityid is null;