select 
	
	apsp.countryid,
	apsp.stateprovinceid,
	apsp.salesterritory,
	apsp.stateprovincename,
	apsp.stateprovincecode	

from application.stateprovinces as apsp

left join

	application.stateprovinces_archive  as apspa
on apsp.countryid = apspa.countryid
and apsp.stateprovinceid = apspa.stateprovinceid;