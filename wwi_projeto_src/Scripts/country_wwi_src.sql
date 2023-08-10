select
	
	apcnt.countryid,
	apcnt.countryname,
	apcnt.subregion,
	apcnt.formalname,
	apcnt.continent,
	apcnt.region,
	apcnt.latestrecordedpopulation,
	apcnt.isoalpha3code

from application.countries as apcnt

left join
	application.countries_archive as apca
	
on apcnt.countryid = apca.countryid;