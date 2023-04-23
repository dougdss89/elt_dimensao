use AdventureWorks2019;
go

with fact_elt as (

select
	cast(sso.SalesOrderID as int) as salesorderid,
	cast(sso.SalesOrderDetailID as int) as detailorderid,
	cast(soh.OrderDate as date) as orderdate,
	cast(soh.ShipDate as date) as shipdate,
	cast(soh.DueDate as date) as duedate,
	cast(PurchaseOrderNumber as varchar(40)) as purchasenumber,
	cast(SalesOrderNumber as varchar(20)) as salesnumber,
	cast(CarrierTrackingNumber as varchar(20)) as carriertrackingserial,
	cast(AccountNumber as varchar(20)) as serialaccount,
	cast(CreditCardApprovalCode as varchar(20)) as cardapprovalcode,
	cast(CreditCardID as int) as creditcardid,
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
from Sales.SalesOrderDetail as sso
left join
	Sales.SalesOrderHeader as soh
on sso.SalesOrderID = soh.SalesOrderID),

remove_null as (

select 
	salesorderid,
	detailorderid,
	orderdate,
	shipdate,
	duedate,
	coalesce(purchasenumber, salesnumber + 'ONL') as purchasenumber,
	coalesce(carriertrackingserial, 'Picked Up on Site') as carriertrackingserial,
	serialaccount,
	coalesce(cardapprovalcode, 'Cash Payment') as cardapprovalcode,
	coalesce(creditcardid, 0) as creditcardid,
	coalesce(salespersonid, 0) as salespersonid,
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