
with etl_prod_category as (

select 
	ProductCategoryID,
	[name] as categoryname
from Production.ProductCategory)

select * from etl_prod_category;
