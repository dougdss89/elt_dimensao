select 
    getdate()               as getdate,
    current_timestamp       as [current_timestamp],
    getutcdate()            as getutcdate,
    sysdatetime()           as sysdatetime,
    sysutcdatetime()        as sysutcdatetime,
    sysdatetimeoffset()     as sysdatetimeoffset,
    timefromparts(11, 23, 45, 00, 00) as from_part --cria tempo a partir de valores informados

select cast(sysdatetime() as date) as sysdatetime_date
select cast(sysdatetime() as time) as sysdatetime_time

