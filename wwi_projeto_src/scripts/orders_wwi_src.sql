select 

	so.OrderID,
	sol.OrderLineID,
	so.OrderDate,
	so.ExpectedDeliveryDate,
	so.PickingCompletedWhen,
	so.CustomerID,
	so.SalespersonPersonID,
	so.PickedByPersonID,
	so.ContactPersonID,
	so.CustomerPurchaseOrderNumber,
	sol.PackageTypeID,
	sol.Quantity,
	sol.UnitPrice,
	sol.TaxRate,
	sol.PickedQuantity,
	sol.PickingCompletedWhen

from Sales.Orders as so

left join
	Sales.OrderLines as sol
on so.OrderID = sol.OrderID;