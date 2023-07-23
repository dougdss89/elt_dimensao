select 
	apc.stateprovinceid,
	apc.cityid,
	apc.cityname,
	apc.latestrecordedpopulation,
	row_number() over (partition by apc.cityname
						order by apc.latestrecordedpopulation desc) as rn_city,
	cast(apc.validfrom as date) as validfrom

from application.cities as apc

left join

	application.cities_archive  as apca

on apc.cityid = apca.cityid
--order by apc.cityname;

with elt_cities_wwi as(

select 
	
	apc.stateprovinceid,
	apc.cityid,
	apc.cityname,
	coalesce(apc.latestrecordedpopulation, 0) as populationrecord,
	apc.validfrom

from application.cities as apc

	left join
	
	application.cities_archive  as apca
on apc.cityid = apca.cityid 
and apc.stateprovinceid = apca.stateprovinceid),

final_elt_cities as (

select

	stateprovinceid,
	cityid,
	cityname,
	populationrecord,
	row_number() over (partition by cityname
						order by populationrecord desc) as rn_city,
	cast(validfrom as date) as validfrom
from elt_cities_wwi)

select * from final_elt_cities
where rn_city = 1;