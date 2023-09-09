select top(5) * from Warehouse.StockGroups;

select top(5) * from Warehouse.StockGroups_Archive;

select  * from Warehouse.StockItems;

select  * from Warehouse.StockItems_Archive order by StockItemID

select 

    wsi.StockItemID,
    wsi.StockItemName,
    wsi.SupplierID,
    wsi.ColorID,
    wsi.UnitPackageID,
    wsi.OuterPackageID,
    wsi.QuantityPerOuter,
    wsi.Brand,
    wsi.[Size],
    wsi.LeadTimeDays,
    wsi.QuantityPerOuter,
    wsi.IsChillerStock,
    wsi.Barcode,
    wsi.TaxRate,
    wsi.UnitPrice,
    wsi.RecommendedRetailPrice,
    wsi.TypicalWeightPerUnit,
    wsi.MarketingComments,
    wsi.CustomFields,
    wsi.tags,
    wsi.ValidFrom,
    wsi.ValidTo

from Warehouse.StockItems as wsi

left join

    Warehouse.StockItems_Archive as wsia

on wsi.StockItemID = wsia.StockItemID;