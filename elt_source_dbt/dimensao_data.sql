use AdventureWorks2019;
go

with elt_dimdate as (
select
	distinct(cast(orderdate as date)) as orderdate
from Sales.SalesOrderHeader),

cria_dimdate as (

select
	orderdate,
	year(orderdate) as orderyear,
	'FY' + cast(year(orderdate) as varchar(5)) as fiscalyear,
	datename(mm,orderdate) as month_name,
	substring(cast(datename(m, orderdate) as varchar(10)),1,3) as monthabrv,
	datepart(m,orderdate) as monthnum,
	case
		when datepart(m, orderdate) between 1 and 3 then 'Q1'
		when datepart(m, orderdate) between 4 and 6 then 'Q2'
		when datepart(m, orderdate) between 6 and 9 then 'Q3'
		when datepart(m, orderdate) between 9 and 12 then 'Q4'
	end as quartermonth,
	datename(w, orderdate) as weekname,
	substring(cast(datename(w, orderdate) as varchar(10)),1,3) as weeknameabrv,
	datename(ww, orderdate) as weeknuminyear,
	datepart(d, orderdate) as daynum,
	case 
		when datepart(d, orderdate) = 1 then 'Yes'
		else 'No'
	end as ismonthbegin,
	case
		when cast(datename(w, orderdate) as varchar(10)) = 'monday' then 'Yes'
		else 'No'
	end as isweekbegin,
	upper(cast(year(orderdate) as varchar(5)) + '_' + substring(cast(datename(m, orderdate) as varchar(3)),1,3)) as yearmonth,
	case	
		when year(orderdate) % 4 = 0 or year(orderdate) % 400 = 0 and year(orderdate) % 100 <> 0  then 'Yes'
	else 'No'
	end as leapyear

	
from elt_dimdate)

select * from cria_dimdate
order by orderdate;
