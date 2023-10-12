select

	wsg.StockGroupID,
	wsg.StockGroupName,
	wsg.ValidFrom,
	wsg.ValidTo

from warehouse.stockgroups as wsg

left join
	
	Warehouse.StockGroups_Archive as wsga
on wsg.StockGroupID = wsga.StockGroupID;