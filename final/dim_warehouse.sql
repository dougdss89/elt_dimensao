with elt_dimwarehouse as (

select
	
	ppi.locationid,
	shelf,
	bin,
	quantity,
	productid,
	[availability] as prodavailable,
	cast(costrate as numeric(12,2)) as costrate,
	pl.[name] as processname,
	coalesce(pbm.billofmaterialsid, 0) as billofmaterialsid,
	coalesce(componentid, 0) as componentid,
	coalesce(cast(startdate as date), '0001-01-01') as startdate,
	coalesce(cast(enddate as date), '9999-12-31') as enddate,
	coalesce(perassemblyqty, 0) as qtyperassembly,
	coalesce(pbm.unitmeasurecode, 'Not Available') as measurecode,
	coalesce(pum.[name], 'Not Availble') as measurename, 
	row_number() over (partition by productid, billofmaterialsid, componentid, startdate
						order by productid asc) as step

from production.productinventory as ppi
	left join
	production.[location] as pl
on ppi.locationid = pl.locationid
	left join
	production.billofmaterials as pbm
on ppi.productid = pbm.productassemblyid
	left join
	Production.UnitMeasure as pum
on pbm.UnitMeasureCode = pum.UnitMeasureCode),

final_elt_dwarehouse as (

	select 
		locationid,
		shelf,
		bin,
		quantity,
		productid,
		prodavailable,
		costrate,
		processname,
		billofmaterialsid,
		componentid,
		startdate,
		enddate,
		qtyperassembly,
		measurecode,
		'Step ' + cast(step as varchar(2)) as steps
	from elt_dimwarehouse)

select * from final_elt_dwarehouse;