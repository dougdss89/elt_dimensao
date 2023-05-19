use AdventureWorks2019;
go

select
	ppv.productid,
	pv.businessentityid,
	accountnumber,
	name,
	creditrating,
	preferredvendorstatus,
	averageleadtime,
	standardprice,
	lastreceiptcost,
	lastreceiptdate,
	minorderqty
	maxorderqty,
	onorderqty,
	unitmeasurecode
from Purchasing.Vendor as pv
	left join
	purchasing.productvendor as ppv
on pv.businessentityid = ppv.businessentityid;
go
