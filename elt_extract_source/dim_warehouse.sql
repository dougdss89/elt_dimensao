select
	ppi.locationID,
	ppi.shelf,
	ppi.bin,
	ppi.quantity,
	ppi.productid,
	pl.[availability],
	pl.costrate,
	pl.[name],
	pbm.billofmaterialsid,
	pbm.componentid,
	pbm.startdate,
	pbm.bomlevel,
	pbm.enddate,
	pbm.perassemblyqty,
	pbm.unitmeasurecode
from production.productinventory as ppi
	left join
	production.[location] as pl
on ppi.locationid = pl.locationid
	left join
	production.billofmaterials as pbm
on ppi.productid = pbm.productassemblyid