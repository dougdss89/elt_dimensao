select 

	StockItemID,
	QuantityOnHand,
	BinLocation,
	LastStocktakeQuantity,
	LastCostPrice,
	TargetStockLevel,
	ReorderLevel,
	LastEditedWhen

from warehouse.StockItemHoldings;