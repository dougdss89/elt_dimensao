select 

	ppl.purchaseorderid,
	purchaseorderlineid,
	stockitemid,
	packagetypeid,
	orderedouters,
	expectedunitpriceperouter,
	receivedouters,
	ppo.supplierid,
	ppo.deliverymethodid,
	ppo.contactpersonid,
	cast(lastreceiptdate as date) as lastreceiptdate,
	isorderlinefinalized,
	ppo.orderdate,
	ppo.expecteddeliverydate,
	cast(ppo.lasteditedwhen as date) as lasteditedwhen,
	ppo.supplierreference,
	description
	
from purchasing.purchaseorderlines as ppl

left join

	purchasing.purchaseorders as ppo
	
on ppl.purchaseorderid = ppo.purchaseorderid;