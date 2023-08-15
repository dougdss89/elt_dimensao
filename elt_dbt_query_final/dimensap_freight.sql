select 
	freightkey,
    shipmethodid as shipid,
    [name] as freightname,
    shipbase,
    shiprate,

	case 
		when shipbase < 5.00 then 'Basic'
		when shipbase > 5.00 and shipbase < 10.00 then 'Normal'
		when shipbase > 10.00 and shipbase < 25.00 then 'Express'
		else 'Deluxe'
	end as freightclass
    
from stg_dim.stgfreight;