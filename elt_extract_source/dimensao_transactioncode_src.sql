select
	distinct
	soh.SalesOrderID,
	purchaseordernumber,
	salesordernumber,
	carriertrackingnumber,
	accountnumber,
	CreditCardApprovalCode,
	soh.OnlineOrderFlag
from sales.SalesOrderHeader as soh
	left join
	Sales.SalesOrderDetail as sod
on soh.SalesOrderID = sod.SalesOrderID;