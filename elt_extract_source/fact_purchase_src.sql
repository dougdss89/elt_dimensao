use AdventureWorks2019;
go

select 
	pod.PurchaseOrderID,
	pod.PurchaseOrderDetailID,
	poh.revisionnumber,
	poh.[status],
	poh.employeeid,
	poh.vendorid,
	poh.orderdate,
	poh.shipdate,
	pod.duedate,
	shipmethodid,
	pod.productid,
	pod.receivedqty,
	pod.rejectedqty,
	pod.stockedqty,
	pod.unitprice,
	poh.freight,
	poh.taxamt,
	pod.linetotal,
	poh.subtotal,
	poh.totaldue
from Purchasing.PurchaseOrderDetail as pod
left join
	Purchasing.PurchaseOrderHeader as poh
on pod.PurchaseOrderDetailID = poh.PurchaseOrderID;

