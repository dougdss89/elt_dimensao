use AdventureWorks2019;
select
    pp.businessentityid,
    hre.loginid,
    pp.firstname,
    pp.lastname,
    hre.gender,
    hre.birthdate,
    hre.hiredate,
    hre.jobtitle,
    hre.maritalstatus,
    hre.organizationlevel,
    hre.organizationnode,
    hreh.departmentid,
    hreh.startdate,
    hreh.enddate,
    hrd.groupname,
    hrd.[name] as departmentname,
    hreph.payfrequency,
    hreph.rate,
    hreph.ratechangedate,
    ssp.commissionpct,
    ssp.salesquota,
    ssp.bonus,
    sst.[name] as regionname,
    sst.[group] as continentname,
    sst.countryregioncode,
    sst.territoryid,
	SalariedFlag,
	CurrentFlag
from person.person as pp
left join
    humanresources.employee as hre
on pp.businessentityid = hre.businessentityid
left join
    humanresources.EmployeeDepartmentHistory as hreh
on hre.businessentityid = hreh.businessentityid
left join
    humanresources.department as hrd
on hreh.departmentid = hrd.departmentid
left join
    humanresources.employeepayhistory as hreph
on hreph.businessentityid = hre.businessentityid
inner join
    sales.salesperson as ssp
on hre.businessentityid = ssp.businessentityid
left join
    sales.salesterritory as sst
on sst.territoryid = ssp.territoryid
