-- dimensão produto
use AdventureWorks2019;
go

with elt_dim_product as (
select
	pp.productid,
	pp.[name] as productname,
	pp.ProductNumber as productserial,
	coalesce(pps.ProductSubcategoryID, 0) as subcategoryid,
	coalesce(pps.[name], 'Descontinued') as subcategoryname,
	coalesce(ppc.ProductCategoryID, 0) as categoryid,
	case
		when pps.ProductCategoryID is null and pps.[Name] is null and ppc.ProductCategoryID is null and pp.Color is null then 'Descontinued'
		when pp.Color is null then 'Multicolor'
		when pp.color = 'Multi' then 'Multicolor'
		when pp.Color like '%/%' then 'Multicolor'
	else pp.Color
	end as productcolor,
	case
		when pps.ProductCategoryID is null and pps.[Name] is null and ppc.ProductCategoryID is null and pp.ProductLine is null then 'Descontinued'
		when pp.ProductLine = 'R' then 'Road'
		when pp.ProductLine = 'S' then 'Sport'
		when pp.ProductLine = 'M' then 'Mountain'
		when pp.ProductLine = 'T' then 'Touring'
	else 'Accessories'
	end as productline,
	case 
		when pps.ProductCategoryID is null and pps.[Name] is null and ppc.ProductCategoryID is null and pp.Class is null then 'Descontinued'
		when pp.Class = 'L' then 'Light'
		when pp.Class = 'M' then 'Medium'
		when pp.Class = 'H' then 'Heavy'
	else 'Small'
	end as productclass,
	case
		when pp.Style = 'W' then 'Feminine'
		when pp.Style = 'M' then 'Masculine'
		else 'Unissex'
	end as productstyle,
	case
		when pp.ProductSubcategoryID is null and ppc.ProductCategoryID is null then 'Descontinued'
		when ppm.[Name] like 'LL%' then REPLACE(ppm.[Name], 'LL', 'Light')
		when ppm.[name] like 'ML%' then REPLACE(ppm.[Name], 'ML', 'Medium')
		when ppm.[Name] like 'HL%' then REPLACE(ppm.[Name], 'HL', 'Heavy')
	else ppm.[Name]
	end as productmodel,
	case	
		when pp.ProductSubcategoryID is null and ppc.ProductCategoryID is null then 'Descontinued'
		when pp.Size = 'L' then 'Large'
		when pp.Size = 'M' then 'Medium'
		when pp.Size = 'Xl' then 'Extra Large'
		when pp.Size = 'S' then 'Small'
		when pp.Size >= 38 and pp.Size <= 42 then 'Small'
		when pp.Size > 42 and pp.Size <= 50 then 'Medium'
		when pp.Size > 50 and pp.Size <= 60 then 'Large'
		when pp.Size > 60 then 'Extra Large'
	else 'Small Piece'
	end as productsize,
	case
		when pp.ProductSubcategoryID is null and ppc.ProductCategoryID is null then 'Descontinued'
		when pp.Size >= '38' and pp.Size <= '70' then pp.size + ' - Centimeters'
	else 'Not Available'
	end as sizeunit,
	coalesce(pp.[Weight], 0.00) as productweight,
	pp.StandardCost as productcost,
	pp.ListPrice as productprice,
	pp.SafetyStockLevel as stocklevel,
	pp.ReorderPoint as reorder,
	case 
		when pp.DaysToManufacture <= '1' then 'Fast'
		when pp.DaysToManufacture > '1' and pp.DaysToManufacture <= '3' then 'Normal'
		when pp.DaysToManufacture > '3' then 'Slowly'
	end as daystomanufacture,
	cast(pp.SellStartDate as date) as sellstartdate,
	case
		when pp.ProductSubcategoryID is null and ppc.ProductCategoryID is null then (select cast(max(sellstartdate) as date) from Production.Product)
		when SellEndDate is not null then cast(SellEndDate as date)
	else '9999-12-31'
	end as sellenddate
from Production.Product as pp
left join
	Production.ProductSubcategory as pps
on pp.ProductSubcategoryID = pps.ProductSubcategoryID
left join
	Production.ProductCategory as ppc
on pps.ProductCategoryID = ppc.ProductCategoryID
left join
	Production.ProductModel as ppm
on pp.ProductModelID = ppm.ProductModelID),

converte_dim_produto as (

select 
	cast(productid as smallint) as productid,
	cast(productname as nvarchar(50)) as productname,
	cast(productserial as nvarchar(20)) as productserial,
	cast(subcategoryid as smallint) as subcategoryid,
	cast(subcategoryname as varchar(15)) as subcategoryname,
	cast(categoryid as smallint) as categoryid,
	cast(productcolor as varchar(15)) as productcolor,
	cast(productline as varchar(15)) as productline,
	cast(productclass as varchar(15)) as productclass,
	cast(productstyle as varchar(10)) as productstyle,
	cast(productmodel as nvarchar(50)) as productmodel,
	cast(productsize as varchar(15)) as productsize,
	cast(sizeunit as nvarchar(20)) as sizeunit,
	cast(productweight as numeric(12,2)) as productweight,
	cast(productcost as numeric(12, 2)) as productcost,
	cast(productprice as numeric(12,2)) as productprice,
	cast(stocklevel as smallint) stocklevel,
	cast(reorder as smallint) as reorder,
	cast(daystomanufacture as varchar(10)) as daystomanufacture,
	sellstartdate,
	sellenddate
from elt_dim_product),

dim_produto_final as(

select * from converte_dim_produto)

select * from dim_produto_final;


/*
select 
ProductID, 
REPLACE(value, ',', ''),
row_number() over (partition by productid
					order by productid) as rn
from Production.Product
cross apply (select 
				value
				from
				string_split([name], ' ')) as a;
*/