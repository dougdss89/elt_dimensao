with fact_elt as (

select

	cast(SalesOrderID as int) as salesorderid,
	cast(SalesOrderDetailID as int) as detailorderid,
	cast(OrderDate as date) as orderdate,
	cast(ShipDate as date) as shipdate,
	cast(DueDate as date) as duedate,
	cast(SalesPersonID as smallint) as salespersonid,
	cast(ProductID as smallint) as productid,
	cast(CustomerID as int) as customerid,
	cast(ShipMethodID as tinyint) as shippingid,
	cast(TerritoryID as tinyint) as territoryid,
	cast(SpecialOfferID as tinyint) as promotionid,
	cast(orderqty as int) as quantity,
	cast(unitprice as numeric(12,2)) as unitprice,
	cast(unitpricediscount as numeric(12,3)) as discountprice,
	cast(taxamt as numeric(9,2)) as taxes,
	cast(freight as numeric(9,2)) as freight,

	case
		when OnlineOrderFlag = 1 then 'yes'
		else 'no'
	end as isonlineorder,

	cast(LineTotal as numeric(12,2)) as linetotal
from stg_fact.stgfactsales),

remove_null as (

select 

	salesorderid,
	detailorderid,
	orderdate,
	shipdate,
	duedate,
	productid,
	customerid,
	shippingid,
	territoryid,
	promotionid,
	quantity,
	unitprice,
	discountprice,
	taxes,
	freight,
	linetotal,
	isonlineorder

from fact_elt),

final_elt as (

select * from remove_null)

select * from final_elt;

