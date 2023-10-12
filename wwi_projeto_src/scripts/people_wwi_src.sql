
select
	
	appl.personid,
	appl.searchname,
	appl.fullname,
	appl.preferredname,
	appl.logonname,
	appl.userpreferences,
	appl.customfields,
	appl.isemployee,
	appl.ispermittedtologon,
	appl.issalesperson

from application.people as appl

left join
	
	application.people_archive as appla
	
on appl.personid = appla.personid;