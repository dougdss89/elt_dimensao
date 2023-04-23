select
	sso.SalesOrderID,
	sso.SalesOrderDetailID,
	soh.OrderDate,
	soh.ShipDate,
	soh.DueDate,
	PurchaseOrderNumber,
	SalesOrderNumber,
	CarrierTrackingNumber,
	AccountNumber,
	CreditCardApprovalCode,
	CreditCardID,
	SalesPersonID,
	ProductID,
	CustomerID,
	ShipMethodID,
	TerritoryID,
	SpecialOfferID,
	orderqty,
	unitprice,
	unitpricediscount,
	taxamt,
	freight,
	OnlineOrderFlag,
	LineTotal
from Sales.SalesOrderDetail as sso
left join
	Sales.SalesOrderHeader as soh
on sso.SalesOrderID = soh.SalesOrderID