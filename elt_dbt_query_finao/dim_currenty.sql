
select 
    currencykey,
    currencyrateid,
    currencycode,
    [name] as currencyname,
    countryregioncode,
    fromcurrencycode,
    tocurrencycode,
    cast(averagerate as numeric (12,2)) as averagerate,
    cast(endofdayrate as numeric(12, 2)) as endofdayrate,
    currencyratedate

from stg_dim.stgcurrency;