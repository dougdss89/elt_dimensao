select
    pp.ProductID,
    pp.[name] as productname,
    pp.productnumber as productserial,
    pps.productsubcategoryid as subcategoryid,
    pps.[name] as subcategoryname,
    ppc.productcategoryid as categoryid,
    ppc.[name] as categoryname,
    pp.color,
    pp.class,
    pp.size,
    pp.productline,
    pp.productmodelid,
    ppm.[name] as modelname,
    pp.style,
    pp.listprice,
    pp.standardcost,
    sellstartdate,
    pp.sellenddate,
    pp.safetystocklevel,
    pp.reorderpoint,
    pp.sizeunitmeasurecode,
    pp.weightunitmeasurecode,
    pp.daystomanufacture,
    pp.discontinueddate
from production.product as pp
left join
    production.productsubcategory as pps
on pp.productsubcategoryid = pps.productsubcategoryid
left join
    production.productcategory as ppc
on pps.productcategoryid = ppc.productcategoryid
left join
    production.productmodel as ppm
on pp.productmodelid = ppm.productmodelid