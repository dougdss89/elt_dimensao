
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
	pp.demographics.value('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/ns:IndividualSurvey/ns:NumberCarsOwned)[1]','smallint') AS NumberCarsOwned,
	pp.rowguid
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
									FROM HumanResources.employee)