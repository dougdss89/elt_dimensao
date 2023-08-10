select

	pcs.supplierid,
	pcs.deliverymethodid,
	pcs.primarycontactpersonid,
	pcs.postaladdressline1,
	pcs.postaladdressline2,
	pcs.bankaccountbranch,
	pcs.paymentdays,
	pcs.bankinternationalcode,
	pcs.deliverymethodid ,
	pcs.deliverypostalcode,
	pcs.bankaccountcode,
	pcs.postalpostalcode,
	pcs.deliverylocation,
	pcs.supplierreference,
	pcs.postalcityid,
	pcs.deliverycityid,
	pcs.suppliercategoryid,
	pcs.suppliername,
	pcs.paymentdays ,
	pcs.deliveryaddressline1,
	pcs.deliveryaddressline2,
	psc.suppliercategoryname as categoryname

from purchasing.suppliers as pcs

left join

	purchasing.suppliers_archive as pcsa
	
on pcs.supplierid  = pcsa.supplierid

left join

	purchasing.suppliercategories as psc
	
on pcs.suppliercategoryid  = psc.suppliercategoryid