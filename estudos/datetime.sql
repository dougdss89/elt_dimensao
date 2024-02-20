use TSQLV6;
go

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

drop table if exists testedatetime;
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

-- datepart function
select DATEPART(DD, GETDATE()) as daypart;
go

-- desafios de trabalhar com date and time

-- literals

/*
tem que tomar cuidado com a forma como se utiliza as datas pois o SQL Server pode considerar D/M/A 
retornando resultando incorreto

seja com - ou / ele reconhece como data

No postgresql, ele é mais sensível com a ordem que colocamos o mês. Se for m/d/a acusará erro, o mesmo vale para a/m/d
Acredito que isso aconteça pois o engine interno do banco não consegue converter corretamente.

Ao que tudo indica, ambos os bancos tentam converter para um formato de data, mas dependendo da ordem, ele não consegue
*/
select custid, empid, orderdate from Sales.Orders
where orderdate = '2020-08-27';

select custid, orderid, orderdate
from sales.orders
where orderdate = '08/27/2020';
go

select custid, orderid, orderdate
from sales.orders
where orderdate = '2020/08/27';
go

select custid, orderid, orderdate -- essa query acusa falha
from sales.Orders
where orderdate = '2020/27/08';
go

set language us_english

select custid, orderid, orderdate -- essa query acusa falha
from sales.Orders
where orderdate = '2020/08/27';
go

--IDENTIFY WEEK DAYS

/*
o "problema" do idioma é que ele determina o formato da data 
e junto, o primeiro dia da semana

Então as funções datepart e dateformat, serão afetadas

também não é aconselhável alterar a configuração geral de idioma, para não
alterar o caches de query plan e cálculos de sessões com outros idiomas.

*/
select * from sys.syslanguages
-- na minha versão começa no domingo
select datepart(WEEKDAY, SYSDATETIME()) as weekdaynumber;
select DATENAME(WEEKDAY, getdate())
-- o ideal do cálculo de data é rodar a função datefirst para calcular corretamente.
select @@DATEFIRST;

select
	orderdate,
	case
		when DATENAME(dw, orderdate) like 'monday' then DATEPART(dw, orderdate)
	end as 'weekname'
from Sales.Orders;

use TSQLV6;
select
	orderdate, 
	datename(weekday, orderdate),
	DATEPART(weekday, orderdate) as daynum 
from sales.Orders
where DATEPART(weekday, orderdate) = @@DATEFIRST % 7 +1;

-- domingo com primeiro dia

select DATEDIFF(day, '19000107', sysdatetime()) % 7 + 1;

select DATEPART(weekday, sysdatetime()) -- domingo já é considerado o 1º dia

select * from sys.syslanguages;

use AdventureWorks2019;
select 
	orderdate,
	datename(dw, orderdate) as weekname,
	datepart(dw, orderdate) as daynumber,
	case
		when datename(dw, orderdate) = 'monday' then 'week begin'
		when datepart(dw, orderdate) in(7,1) then 'weekend'
	else 'week'
	end as isweekbegin
from Sales.SalesOrderHeader;

-- WEEKDAY FIXO

/*
o que acontece é o seguinte:
caso a linguagem do SQL Server mude, o dia da semana @@datefirst, pode mudar.
para manter fixo, isso é, começando na segunda, existe uma solução.

com a seguinte query abaixo, é possível.

A query torna se torna neutra ao idioma utilizado, considerando a segunda como o 1º dia, em qualquer cenário.

Mesmo em cenários onde o domingo é o primeiro dia, a segunda passa a ser o primeiro dia.
*/
set language 'us_english'
declare @inputdate as date,
		@compensatedate as tinyint,
		@diffdate as date

set @inputdate = SYSDATETIME()
set @compensatedate = @@DATEFIRST

select DATEPART(weekday, DATEADD(day, @compensatedate - 1, @inputdate)) as english_1, datename(weekday, DATEADD(day, @compensatedate - 1, @inputdate)) as primeday;
go


-- teste com o idioma Inglês britânico
set language 'British English';
declare @inputdate as date,
		@compensatedate as tinyint,
		@diffdate as date

set @inputdate = SYSDATETIME()
set @compensatedate = @@DATEFIRST

select DATEPART(weekday, DATEADD(day, @compensatedate - 1, @inputdate)) as britsh_1;
go

select @@DATEFIRST;
select * from sys.syslanguages;
select datepart(weekday, dateadd(day, @@datefirst - 1, '2024-01-23'))

set language 'english'
select @@DATEFIRST as firstday, datename(WEEKDAY, @@DATEFIRST) beginweek, DATEPART(weekday, SYSDATETIME())as today;

set language 'British English';
select @@DATEFIRST as firstday, datename(WEEKDAY, @@DATEFIRST) beginweek, DATEPART(weekday, SYSDATETIME())as today;

/*
o que acontece é o seguinte:
dependendo do idioma e cultura, o primeiro dia da semana é Domingo(Brasil, EUA)
em outros locais,  é Segunda(Inglaterra)

quando é Domingo, terça é o terceiro dia da semana, do contrário, segundo.

Caso isso se torne um problema, talvez seja interessante padronizar para segunda, como 1º dia. Ou Domingo.

Pq em caso de uma empresa global, atuando em uma cultura de data diferente, se for olhar qual dia da semana há mais compra,
dependendo da perspectiva, verá que é o 1º dia, e esse cai Domingo, quando estão achando que é segunda.


-----------
Estava estudando SQL agora pouco, me aprofundando em manipulação de datas. 



Não é tão simples quanto parece e acabei pensando em uma situação:



Existem culturas que consideram o Domingo como 1º dia (Brasil é um deles) e outras que consideram a Segunda.



Dependendo do SGBD utilizado, pode gerar uma confusão.



O PostgreSQL começa na Segunda e o SQL Server, depende da linguagem instalada - pode ser alterada com o "set language".



Considerando que uma empresa global atuando em diferentes culturas fosse olhar um relatório gerado de uma base com o 1º dia Domingo e fosse tomar alguma ação, não estaria sendo induzida ao erro olhando de forma isolada para aquela região?
*/

set language 'brazilian'
select 
	datename(weekday, getdate()) as diahoje,
	datepart(dw, getdate()) as numdia_hoje,
	datename(weekday, GETDATE() - 1) as diasemana, 
	datepart(dw, getdate()-1) as daynumber, 
	datename(weekday, getdate()-2) as retrasado, 
	DATEPART(dw, getdate()-2) as retrasado_daynumber,
	datename(weekday, @@datefirst);

set language 'british'
select 
	datename(weekday, getdate()) as diahoje,
	datepart(dw, getdate()) as numdia_hoje,
	datename(weekday, GETDATE() - 1) as diasemana, 
	datepart(dw, getdate()-1) as daynumber, 
	datename(weekday, getdate()-2) as retrasado, 
	DATEPART(dw, getdate()-2) as retrasado_daynumber,
	datename(weekday, @@datefirst);

-- primeiro, ultimo e próximo dia

select DATEADD(day, datediff(day, '19000101', sysdatetime()), '19000101')

select dateadd(day, datediff(month, '19000101', sysdatetime()), '19000101');

select DATEFROMPARTS(year(sysdatetime()), month(sysdatetime()), 1); -- como formar o primeiro dia do mês.

-- isso vai me ajudar a montar uma dimdate melhor
-- formando o primeiro dia do mês com datefromparts
select 
		datefromparts(year(sysdatetime()), month(sysdatetime()), 1) as firstday,
		DATENAME(weekday, datefromparts(year(sysdatetime()), month(sysdatetime()), 1)) as weekdayoffirstday;
go

-- para o último dia, o SQL Server possui a função eomonth
select 
	datename(weekday, eomonth(getdate())) as weekname_lastday;
go

