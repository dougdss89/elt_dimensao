select 
	pv.businessentityid,
	accountnumber,
	pv.name as vendorname,
	ppv.productid,
	pp.name as productname,
	case 
		when creditrating = 1 then 'Premier'
		when creditrating between 2 and 3 then 'Super class'
		when creditrating = 4 then 'Normal'
		when creditrating = 5 then 'Attention'
	else 'No Classification'
	end as ratingclass,
	creditrating,
	case
		when preferredvendorstatus = 1 then 'Yes'
		else  'No'
	end as preferredevendorstatus,
	preferredvendorstatus,
	averageleadtime,
	standardprice,
	cast(lastreceiptcost as numeric(12,2)) as lastreceiptcost,
	cast(lastreceiptdate as date) as lastreceiptdate,
	minorderqty
	maxorderqty,
	coalesce(onorderqty, 0) as onorderqty,
	case 
		when unitmeasurecode = 'ea' then 'Each'
		when unitmeasurecode = 'cs' then 'Case'
		when unitmeasurecode = 'pak' then 'Pack'
		when unitmeasurecode = 'dz' then 'Dozen'
		when unitmeasurecode = 'ctn' then 'Carton'
		when unitmeasurecode = 'gal' then 'Galoon'
	else 'Unknown'
	end as unitmeasure
from Purchasing.Vendor as pv
	inner join
	purchasing.productvendor as ppv
on pv.businessentityid = ppv.businessentityid
	inner join
	Production.Product as  pp
on pp.ProductID = ppv.ProductID;
go