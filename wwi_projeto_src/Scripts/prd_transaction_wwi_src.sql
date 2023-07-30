select 

	StockItemTransactionID,
	StockItemID,
	TransactionTypeID,
	CustomerID,
	InvoiceID,
	SupplierID,
	PurchaseOrderID,
	Quantity,
	LastEditedBy,
	TransactionOccurredWhen
	

from Warehouse.StockItemTransactions;
go