with elt_dim_vendor as (

	select
		hre.businessentityid as buyerid,
		firstname,
		lastname,
		loginid,
		birthdate,
		case
			when maritalstatus = 'm' then 'Maried'
			else 'Single'
		end as maritalstatus,
		case 
			when gender = 'f' then 'Female'
			else 'Male'
		end as gender,
		hiredate,
		--hre.jobtitle,
		hrd.departmentid,
		[name] as jobtitle,
		groupname,
		payfrequency,
		cast(rate as numeric(12,2)) as payment,
		ratechangedate,
		startdate,
		coalesce(enddate, '9999-12-31') as enddate,
		salariedflag,
		currentflag
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
where hre.jobtitle = 'buyer' or hre.jobtitle like 'purchasing%')

select * from elt_dim_vendor
order by startdate, BusinessEntityID
go