with pre_vendor_elt as (
select 
	
	pv.businessentityid as vendorid,
	accountnumber as vendoraccount,
	ppv.productid as deliveryprodid,
	pp.[name] as deliveryprodname, -- ajustar para o nome da fonte no dbt
	creditrating,
	case
		when creditrating = 1 then 'Premier'
		when creditrating between 2 and 3 then 'Super Class'
		when creditrating = 4 then 'Normal'
		when creditrating = 5 then 'Attention'
	else 'Default'
	end as creditclass,
	case
		when  averageleadtime between 0 and 10 then 'Fast'
		when  averageleadtime > 10 and  averageleadtime <= 20 then 'Rapid'
		when  averageleadtime > 20 and  averageleadtime <= 30 then 'Normal'
		when  averageleadtime > 30 and  averageleadtime <= 45 then 'Attention'
		when  averageleadtime is null then 'Not Available'
	else 'Special Request'
	end as leadtimerank,
	averageleadtime,
	standardprice,
	cast(lastreceiptcost as numeric(12, 2)) as lastreceiptcost,
	cast(lastreceiptdate as date) as lastreceiptdate,
	coalesce(onorderqty, 0) as onorderqty,
	pum.unitmeasurecode as measurecode,
	pum.[name] as measurename,
	case
		when preferredvendorstatus = 1 then 'Yes'
		else 'No'
	end as ispreferredvendor
from Purchasing.Vendor as pv
	left join
	purchasing.productvendor as ppv
on pv.businessentityid = ppv.businessentityid
	left join
	Production.Product as  pp
on pp.ProductID = ppv.ProductID
	left join
	production.UnitMeasure as pum
on pum.UnitMeasureCode = ppv.UnitMeasureCode),

final_vendor as(
select 
	vendorid,
	vendoraccount,
	coalesce(deliveryprodid, 0) as deliveryprodid,
	coalesce(deliveryprodname, 'Not Available') as deliveryprodname,
	creditrating,
	creditclass,
	coalesce(averageleadtime, 0) as averageleadtime,
	leadtimerank,
	case
		when leadtimerank = 'rapid' and averageleadtime < 10 then 'Small Pieces'
		when leadtimerank = 'rapid' and averageleadtime > 10 and averageleadtime <= 20 then 'Medium Pieces'
		when leadtimerank = 'Normal' then 'Large Pieces'
		when leadtimerank = 'attention' then 'Extra Large Pieces'
	else 'Very Large Pieces'
	end as deliveredtype,
	coalesce(standardprice, 0.00) as standardprice,
	coalesce(lastreceiptcost, 0.00) as lastreceiptcost,
	coalesce(lastreceiptdate, '9999-12-31') as lastreceiptdate,
	onorderqty,
	coalesce(measurecode, 'Not Available') as measurecode,
	coalesce(measurename, 'N/A') as measurename,
	ispreferredvendor
from pre_vendor_elt)

select * from final_vendor;
