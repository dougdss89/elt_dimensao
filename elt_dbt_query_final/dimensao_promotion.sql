with elt_promo as (

select 
	promotionkey,
    specialofferid as promotionid,
    [description] as promotiondescription,
    discountpct as discountpercent,
    [type] as promotiontype,
    category as promocategory,
    minqty,

    case
        when maxqty is null and [type] like 'No disc%' then 0
        when maxqty is null and MinQty > 60 then 70
        when maxqty is null and  [type] like 'discontinued%' then 1000
        when MaxQty is null and [type] like 'excess%' then 1000
        when maxqty is null and [type] like 'seasonal%' then 100
        when maxqty is null and [type] like 'new pro%' then 10
    else maxqty
    end as maxqty,

    cast(startdate as date) as startdate,
    cast(enddate as date) as enddate,

    case 
        when enddate is not null and enddate >= (select max(cast(orderdate as date)) from stg_fact.stgfactsales) or [type] not like 'discontinued%' then 'Yes'
        else 'No'
    end as ispromoactive

from stg_dim.stgpromotion)


select * from elt_promo;


--select max(cast(orderdate as date)) from Sales.SalesOrderHeader;
