use AdventureWorks2019;
go

select
	ppv.productid,
	pv.businessentityid,
	accountnumber,
	pv.name,
	pvc.contacttype,
	pvc.firstname,
	pvc.lastname,
	pvc.phonenumber,
	pvc.phonenumbertype,
	creditrating,
	preferredvendorstatus,
	averageleadtime,
	standardprice,
	lastreceiptcost,
	lastreceiptdate,
	minorderqty
	maxorderqty,
	onorderqty,
	unitmeasurecode,
	pva.stateprovincename,
	pva.countryregionname,
	pva.addressline1,
	pva.addressline2,
	pva.city,
	pva.postalcode
from Purchasing.Vendor as pv
	left join
	purchasing.productvendor as ppv
on pv.businessentityid = ppv.businessentityid
	left join
	purchasing.vVendorWithAddresses as pva
on pv.businessentityid = pva.businessentityid
	left join
	purchasing.vVendorWithContacts as pvc
on pva.businessentityid = pvc.businessentityid
go
