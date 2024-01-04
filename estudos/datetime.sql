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


USE TSQLV6;
go

select  SYSUTCDATETIME();
select SYSUTCDATETIME() as utctime;
go

select SYSDATETIMEOFFSET() as brtime;
go

-- o offset retornado pelo switchoffset é com base no utcdatetimeoffset
select SWITCHOFFSET(sysdatetimeoffset(),'-08:00')
go

create table testedatetime (

id int identity,
insertdate datetime 
constraint testetime default sysdatetimeoffset()
);

waitfor delay '00:00:10';
go
insert into testedatetime
select SYSDATETIMEOFFSET()
go 20

select * from testedatetime;

-- como to utilizando o tempo da tabela, ele adicionou +3 hrs do horário da inserção
select insertdate, SWITCHOFFSET(insertdate, '+03:00')
from testedatetime;

select insertdate, SWITCHOFFSET(insertdate, '-08:00')
from testedatetime;

-- quando utilizo o switchoffset e passo o valor, o que a função retorna é o horário dentro daquele offset informado
-- ai precisaria ver no globo, mas a diferença são de 2hrs pro horário do BR(brasília)
-- o "-03:00' é a diferença pro GMT (greenwich meridian time - eu acho xD)
-- consultando sysutcdatetime, entendemos os valores das diferenças.

select SYSDATETIME() as sysdate, SYSDATETIMEOFFSET() as brtime, SYSUTCDATETIME() as timegmt,  SWITCHOFFSET(SYSDATETIMEOFFSET(), '+12:00');

select * from testedatetime

alter table testedatetime
add dto as todatetimeoffset(insertdate, 3);

select * from testedatetime;

alter table testedatetime
drop column dto;