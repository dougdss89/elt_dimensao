select 
	
	SalesReasonID,
	[name],
	case
		when reasontype = 'other' and [name] = 'price' then 'Lower Price'
		when reasontype = 'other' and [name] = 'manufacturer' then 'Manufacturer campaign'
		when reasontype = 'other' and [name] = 'review' then 'Product Review'
		when reasontype = 'other' and [name] = 'quality' then 'Quality Test'
		when reasontype = 'Marketing' then 'Marketing Campaign'
	else 'Other'
	end as reasontype

from sales.SalesReason;