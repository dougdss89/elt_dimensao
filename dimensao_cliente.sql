use AdventureWorks2019;
go

WITH pre_customer AS (
SELECT
	pp.businessentityid,
	pp.firstname,
	pp.lastname,
	pp.persontype,
	pp.emailpromotion,
	ppt.name AS typephone,
	pph.phonenumber,
	pad.postalcode,
	pat.name,
	emailaddress as email,
	psp.territoryid,
	pcr.name AS countryname,
	pad.stateprovinceid AS stateid,
	psp.countryregioncode AS countrycode,
	psp.stateprovincecode AS statecode,
	psp.name AS statename,
	pad.city,
	pad.addressline1,
	pad.addressline2,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:TotalPurchaseYTD)[1]','numeric(12,2)') AS TotalPurchaseYTD,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:DateFirstPurchase)[1]','date') AS DateFirstPurchase,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:BirthDate)[1]','date') AS BirthDate,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:MaritalStatus)[1]','varchar(10)') AS MaritalStatus,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:YearlyIncome)[1]','varchar(50)') AS YearlyIncome,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:Gender)[1]','varchar(10)') AS Gender,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:TotalChildren)[1]','smallint') AS TotalChildren,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:NumberChildrenAtHome)[1]','smallint') AS NumberChildrenAtHome,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:Education)[1]','varchar(50)') AS Education,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:Occupation)[1]','varchar(50)') AS Occupation,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:HomeOwnerFlag)[1]','varchar(5)') AS HomeOwnerFlag,
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:NumberCarsOwned)[1]','smallint') AS NumberCarsOwned
FROM person.person AS pp
LEFT JOIN
	person.personphone AS pph
ON pp.businessentityid = pph.businessentityid
LEFT JOIN
	person.phonenumbertype AS ppT
ON pph.phonenumbertypeid = ppT.phonenumbertypeid
LEFT JOIN
	person.businessentityaddress AS pba
ON pp.businessentityid = pba.businessentityid
LEFT JOIN
	person.address AS pad
ON pba.addressid = pad.addressid
LEFT JOIN
	person.addresstype AS pat
ON pba.addresstypeid = pat.addresstypeid
LEFT JOIN
	person.emailaddress AS pea
ON pp.businessentityid = pea.businessentityid
LEFT JOIN
	person.stateprovince AS psp
ON pad.stateprovinceid = psp.stateprovinceid
LEFT JOIN
	person.countryregion AS pcr
ON psp.countryregioncode = pcr.countryregioncode
WHERE pp.businessentityid NOT IN (SELECT businessentityid
									FROM HumanResources.employee)),

elt_clientes as (
select
		businessentityid as customerid,
		firstname, 
		lastname,
		persontype,
		case
			when gender = 'F' then 'Female'
			when gender = 'M' then 'Male'
			when gender IS NULL then 'Not Available'
		end as gender,
		case
			when maritalstatus = 'M' then 'Married'
			when maritalstatus = 'S' then 'Single'
			when maritalstatus IS NULL then 'Not Available'
		end as maritalstatus,
		coalesce(cast(birthdate as date), '9999-12-31') as birthdate,
		coalesce(datediff(yy, BirthDate, GETDATE()), 999) as age,
		coalesce(education, 'Not Available') as education,
		coalesce(occupation, 'Not Available') as occupation,
		coalesce(numberchildrenathome, 0) as numchildreninhome,
		coalesce(totalchildren, 0) as totalchildren,
		coalesce(trim(substring(yearlyincome, 0, CHARINDEX('-', yearlyincome))), '0') as minincome,
		coalesce(trim(substring(yearlyincome, CHARINDEX('-', yearlyincome)+1, 20)), '0') as maxincome,
		cast(totalpurchaseytd as numeric(9,2)) as totalpuchased,
		case
			when HOMEOWNERFLAG = 1 then 'Yes'
			else 'No'
		end as ishomeowner,
		coalesce(NUMBERCARSOWNED, 0 ) as numberscarsowned,
		case
			when emailpromotion >= 1 then 'Yes'
			else 'No'
		end as emailpromotion,
		email,
		case
			when typephone = 'cell' then 'Mobile'
			else coalesce(typephone, 'Not Available')
		end as typephone,
		phonenumber,
		coalesce([name], 'Not Available') as typeaddress,
		coalesce(postalcode, 'Not Available') as postalcode,
		coalesce(territoryid, 0) as territoryid,
		coalesce(countryname, 'Not Available') as countryname,
		coalesce(stateid, 0) as stateid,
		coalesce(countrycode, 'Not Available') as countrycode,
		coalesce(statecode, 'Not Available') as statecode,
		coalesce(statename, 'Not Available') as statename,
		coalesce(city, 'Not Available') as city,
		coalesce(addressline1, 'Not Available') as custaddress,
		coalesce(addressline2, 'Not Available') as addressline,
		ROW_NUMBER() over(partition by businessentityid
					order by businessentityid) as rn,
	case 
		when [value] = 'DR.' or [value] = 'Dr' then 'Drive'
		when [value] = 'ST.' or [value] = 'St' or [value] = 'Str' then 'Street'
		when [value] = 'Ave.' or [value] = 'Ave' then 'Avenue'
		when [value] = 'Ln.' or [value] = 'LN' then 'Lane'
		when [value] = 'Ct.' or [value] = 'Ct' then 'Court'
		when [value] = 'Rd.' or [value] = 'RD' then 'Road'
		when [value] = 'Pkwy.' or [value] = 'pkwy' then 'Parkway'
		when [value] = 'pl.' or [value] = 'pl' then 'Plaza'
		when [value] = 'Mt.' or [value] = 'MT' then 'Mount'
		when [value] = 'Blvd.' or [value] = 'Blvd' then 'Boulevard'
		when [value] = 'Rt.' or [value] = 'Rt' then 'Route'
		when [value] = 'Pl.' or [value] = 'Pl' then 'Plaza'
		when [value] = 'N.' then 'North'
	else [value]
	end as tempaddress
from pre_customer
cross apply (select
			*
			from string_split(AddressLine1, ' '))as split),
une_col_um as (
select customerid, tempaddress as line_um from elt_clientes
where rn = 1),

une_col_dois as (
select customerid, tempaddress as line_dois
from elt_clientes
where rn = 2),

une_col_tres as (

select customerid, tempaddress as line_tres 
from elt_clientes
where rn = 3),

une_col_quatro as(
select customerid, tempaddress as line_quatro from elt_clientes
where rn =  4),

une_endereco as (

select 
	col1.customerid, 
	(line_um +' '+ line_dois +' '+ line_tres +' '+ line_quatro) as endr
from une_col_um as col1
left join
	une_col_dois as col2
on col1.customerid = col2.customerid
left join
	une_col_tres as col3
on col1.customerid = col3.customerid
left join
	une_col_quatro as col4
on col1.customerid = col4.customerid),

finaliza_etl as (
select distinct
	cast(eltc.customerid as int) as customerid,
	cast(firstname as varchar(40)) as firstname,
	cast(lastname as varchar(40)) as lastname,
	cast(gender as varchar(10)) as gender,
	cast(maritalstatus as varchar(10)) as maritalstatus,
	cast(birthdate as date) as birthdate,
	cast(age as smallint) as age,
	cast(education as varchar(20)) as education,
	cast(occupation as varchar(20)) as occupation,
	cast(numchildreninhome as tinyint) as numchildreninhome,
	cast(totalchildren as tinyint) as totalchildren,
	case
		when maxincome like 'grea%' then '100000'
	else minincome
	end as minincome,
	cast(maxincome as varchar(20)) as maxincome,
	cast(totalpuchased as numeric(12,2)) as totalpurchased,
	cast(numberscarsowned as tinyint) as numbersofcarsowned,
	cast(email as varchar(100)) as email,
	cast(typephone as varchar(6)) as typephone,
	cast(phonenumber as nvarchar(15)) as phonenumber,
	cast(typeaddress as varchar(6)) as typeaddress,
	cast(territoryid as smallint) as countryid,
	cast(countryname as varchar(15)) as countryname,
	cast(stateid as smallint) as stateid,
	cast(countrycode as char(5)) as countrycode,
	cast(statecode as char(5)) as statecode,
	cast(statename as varchar(25)) as statename,
	cast(city as varchar(20)) as city,
	cast(postalcode as nvarchar(10)) as postalcode,
	coalesce(cast(uned.endr as varchar(80)), 'Not Available') as custaddress,
	cast(addressline as varchar(15)) as addressline,
	cast(ishomeowner as char(5)) as ishomeowner,
	cast(emailpromotion as char(5)) as emailpromotion

from elt_clientes as eltc
	inner join
	une_endereco as uned
on eltc.customerid = uned.customerid)

select * from finaliza_etl;



/*
select
	customerid,
	firstname,
	lastname,
	persontype,
	gender,
	maritalstatus,
	birthdate,
	age,
	education,
	occupation,
	numchildreninhome,
	totalchildren,
	case
		when maxincome like 'great%' then trim(substring(maxincome, charindex('than', maxincome) + 4, 10))
		else minincome
	end as minincome,
	case 
		when maxincome like 'great%' then '100k+'
		else maxincome
	end as maxincome,
	totalpuchased,
	ishomeowner,
	numberscarsowned,
	emailpromotion,
	email,
	typephone,
	phonenumber,
	typeaddress,
	postalcode,
	territoryid,
	countryname,
	stateid,
	countrycode,
	statecode,
	statename,
	city,
	custaddress,
	addressline,
	[value],
	rn
from divide_string)

select * from normaliza_customer_datatype;*/

/*
divide_string as(

select *,
ROW_NUMBER() over(partition by customerid
					order by customerid) as rn,
case 
	when [value] = 'DR.' or [value] = 'Dr' then 'Drive'
	when [value] = 'ST.' or [value] = 'St' or [value] = 'Str' then 'Street'
	when [value] = 'Ave.' or [value] = 'Ave' then 'Avenue'
	when [value] = 'Ln.' or [value] = 'LN' then 'Lane'
	when [value] = 'Ct.' or [value] = 'Ct' then 'Court'
	when [value] = 'Rd.' or [value] = 'RD' then 'Road'
	when [value] = 'Pkwy.' or [value] = 'pkwy' then 'Parkway'
	when [value] = 'pl.' or [value] = 'pl' then 'Plaza'
	when [value] = 'Mt.' or [value] = 'MT' then 'Mount'
	when [value] = 'Blvd.' or [value] = 'Blvd' then 'Boulevard'
	when [value] = 'Rt.' or [value] = 'Rt' then 'Route'
	when [value] = 'N.' then 'North'
else [value]
end as tempaddress

from elt_clientes
cross apply (select
			*
			from string_split(custaddress, ' ')) as split),*/