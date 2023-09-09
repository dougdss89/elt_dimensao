select 

	si.InvoiceID,
	sil.InvoiceLineID,
	si.InvoiceDate,
	si.ConfirmedDeliveryTime,
	si.CustomerID,
	si.BillToCustomerID,
	si.OrderID,
	sil.StockItemID,
	si.DeliveryMethodID,
	si.ContactPersonID,
	si.AccountsPersonID,
	si.SalespersonPersonID,
	si.CustomerPurchaseOrderNumber,
	si.PackedByPersonID,
	sil.PackageTypeID,
	sil.Quantity,
	sil.UnitPrice,
	sil.TaxAmount,
	sil.TaxRate,
	sil.LineProfit,
	sil.ExtendedPrice,
	si.IsCreditNote,
	si.TotalDryItems,
	si.TotalChillerItems,
	si.DeliveryRun,
	si.RunPosition,
	si.ReturnedDeliveryData
	

from Sales.Invoices as si

left join

	Sales.InvoiceLines as sil
on si.InvoiceID = sil.InvoiceID