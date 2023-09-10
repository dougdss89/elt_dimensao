

select
	pw.workorderid,
	pw.productid,
	pw.orderqty,
	pw.stockedqty,
	pw.scrappedqty,
	pw.scrapreasonid,
	pwr.locationid,
	pwr.actualresourcehrs,
	pwr.plannedcost,
	pwr.actualcost,
	pwr.scheduledstartdate,
	pwr.scheduledenddate,
	pwr.actualstartdate,
	pwr.actualenddate,
	pw.startdate,
	pw.enddate,
	pw.duedate
from production.workorder as pw
left join
	production.workorderrouting as pwr
on pw.workorderid = pwr.workorderid