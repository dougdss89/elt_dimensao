select 

	wsi.StockItemID,
	wsi.StockItemName,
	wsi.SupplierID,
	wsi.ColorID,
	wsi.UnitPackageID,
	wsi.OuterPackageID,
	wsi.Brand,
	wsi.Size,
	wsi.LeadTimeDays,
	wsi.QuantityPerOuter,
	wsi.IsChillerStock,
	wsi.Barcode,
	wsi.TaxRate,
	wsi.UnitPrice,
	wsi.RecommendedRetailPrice,
	wsi.TypicalWeightPerUnit,
	wsi.customfields,
	wsi.tags,
	wsi.ValidFrom,
	wsi.ValidTo

from Warehouse.StockItems as wsi

full join
	Warehouse.StockItems_Archive as wsia

on wsi.StockItemID = wsia.StockItemID
where wsi.ValidFrom > '2016-05-31 23:01:00'
go