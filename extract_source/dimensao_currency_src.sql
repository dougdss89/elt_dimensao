
select 
    scr.currencyrateid,
    sc.currencycode,
    sc.[name],
    scrc.CountryRegionCode as countrycode,
    scr.fromcurrencycode,
    scr.tocurrencycode,
    scr.averagerate,
    scr.endofdayrate,
    cast(scr.currencyratedate as date) as currencyratedate
from sales.currency as sc
left join
    sales.countryregioncurrency as scrc
on sc.currencycode = scrc.currencycode
left join
    sales.currencyrate as scr
on sc.currencycode = scr.fromcurrencycode;