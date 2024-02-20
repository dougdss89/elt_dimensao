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

-- o offset retornado pelo switchoffset � com base no utcdatetimeoffset
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

-- como to utilizando o tempo da tabela, ele adicionou +3 hrs do hor�rio da inser��o
select insertdate, SWITCHOFFSET(insertdate, '+03:00')
from testedatetime;

select insertdate, SWITCHOFFSET(insertdate, '-08:00')
from testedatetime;

-- quando utilizo o switchoffset e passo o valor, o que a fun��o retorna � o hor�rio dentro daquele offset informado
-- ai precisaria ver no globo, mas a diferen�a s�o de 2hrs pro hor�rio do BR(bras�lia)
-- o "-03:00' � a diferen�a pro GMT (greenwich meridian time - eu acho xD)
-- consultando sysutcdatetime, entendemos os valores das diferen�as.

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

No postgresql, ele � mais sens�vel com a ordem que colocamos o m�s. Se for m/d/a acusar� erro, o mesmo vale para a/m/d
Acredito que isso aconte�a pois o engine interno do banco n�o consegue converter corretamente.

Ao que tudo indica, ambos os bancos tentam converter para um formato de data, mas dependendo da ordem, ele n�o consegue
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
o "problema" do idioma � que ele determina o formato da data 
e junto, o primeiro dia da semana

Ent�o as fun��es datepart e dateformat, ser�o afetadas

tamb�m n�o � aconselh�vel alterar a configura��o geral de idioma, para n�o
alterar o caches de query plan e c�lculos de sess�es com outros idiomas.

*/
select * from sys.syslanguages
-- na minha vers�o come�a no domingo
select datepart(WEEKDAY, SYSDATETIME()) as weekdaynumber;
select DATENAME(WEEKDAY, getdate())
-- o ideal do c�lculo de data � rodar a fun��o datefirst para calcular corretamente.
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

select DATEPART(weekday, sysdatetime()) -- domingo j� � considerado o 1� dia

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
o que acontece � o seguinte:
caso a linguagem do SQL Server mude, o dia da semana @@datefirst, pode mudar.
para manter fixo, isso �, come�ando na segunda, existe uma solu��o.

com a seguinte query abaixo, � poss�vel.

A query torna se torna neutra ao idioma utilizado, considerando a segunda como o 1� dia, em qualquer cen�rio.

Mesmo em cen�rios onde o domingo � o primeiro dia, a segunda passa a ser o primeiro dia.
*/
set language 'us_english'
declare @inputdate as date,
		@compensatedate as tinyint,
		@diffdate as date

set @inputdate = SYSDATETIME()
set @compensatedate = @@DATEFIRST

select DATEPART(weekday, DATEADD(day, @compensatedate - 1, @inputdate)) as english_1, datename(weekday, DATEADD(day, @compensatedate - 1, @inputdate)) as primeday;
go


-- teste com o idioma Ingl�s brit�nico
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
o que acontece � o seguinte:
dependendo do idioma e cultura, o primeiro dia da semana � Domingo(Brasil, EUA)
em outros locais,  � Segunda(Inglaterra)

quando � Domingo, ter�a � o terceiro dia da semana, do contr�rio, segundo.

Caso isso se torne um problema, talvez seja interessante padronizar para segunda, como 1� dia. Ou Domingo.

Pq em caso de uma empresa global, atuando em uma cultura de data diferente, se for olhar qual dia da semana h� mais compra,
dependendo da perspectiva, ver� que � o 1� dia, e esse cai Domingo, quando est�o achando que � segunda.


-----------
Estava estudando SQL agora pouco, me aprofundando em manipula��o de datas. 



N�o � t�o simples quanto parece e acabei pensando em uma situa��o:



Existem culturas que consideram o Domingo como 1� dia (Brasil � um deles) e outras que consideram a Segunda.



Dependendo do SGBD utilizado, pode gerar uma confus�o.



O PostgreSQL come�a na Segunda e o SQL Server, depende da linguagem instalada - pode ser alterada com o "set language".



Considerando que uma empresa global atuando em diferentes culturas fosse olhar um relat�rio gerado de uma base com o 1� dia Domingo e fosse tomar alguma a��o, n�o estaria sendo induzida ao erro olhando de forma isolada para aquela regi�o?
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

-- primeiro, ultimo e pr�ximo dia

select DATEADD(day, datediff(day, '19000101', sysdatetime()), '19000101')

select dateadd(day, datediff(month, '19000101', sysdatetime()), '19000101');

select DATEFROMPARTS(year(sysdatetime()), month(sysdatetime()), 1); -- como formar o primeiro dia do m�s.

-- isso vai me ajudar a montar uma dimdate melhor
-- formando o primeiro dia do m�s com datefromparts
select 
		datefromparts(year(sysdatetime()), month(sysdatetime()), 1) as firstday,
		DATENAME(weekday, datefromparts(year(sysdatetime()), month(sysdatetime()), 1)) as weekdayoffirstday;
go

-- para o �ltimo dia, o SQL Server possui a fun��o eomonth
select 
	datename(weekday, eomonth(getdate())) as weekname_lastday;
go

