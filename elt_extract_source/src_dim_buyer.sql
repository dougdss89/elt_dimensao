use adventureworks2019;
select distinct
	hre.businessentityid,
	pp.firstname,
	pp.lastname,
	hre.loginid,
	hre.birthdate,
	hre.maritalstatus,
	hre.gender,
	hre.hiredate,
	hre.jobtitle,
	hrd.departmentid,
	hrd.[name],
	hrd.groupname,
	hpe.payfrequency,
	hpe.rate,
	hpe.ratechangedate,
	hrdh.startdate,
	hrdh.enddate,
	hre.salariedflag,
	hre.currentflag
from humanresources.employee as hre
	left join
	humanresources.employeepayhistory as hpe
on hre.businessentityid = hpe.businessentityid
	left join
	humanresources.employeedepartmenthistory as hrdh
on hre.businessentityid = hrdh.businessentityid
	left join
	person.Person as pp
on hre.businessentityid = pp.businessentityid
	left join
	humanresources.department as hrd
on hrd.departmentid = hrdh.departmentid
where hre.jobtitle = 'buyer' or hre.jobtitle like 'purchasing%';
