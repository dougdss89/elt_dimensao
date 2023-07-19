select

    conv_currencykey,
    currencyrateid,
    fromcurrencycode,
    tocurrencycode,
    averagerate,
    endofdayrate,
    currencyratedate

from stg_dim.stgcurrency;
