USE TSQLV6;
GO

set nocount on;


--img01
if object_id ('dbo.myorders') is not null drop table dbo.myorders;
go

select orderid, custid, cast(empid as bigint) as empid, orderdate, shipperid
into dbo.myorders
from sales.orders;
go

select * from dbo.myorders;
GO

--img02
-- excluindo a propriedade identity da coluna
if OBJECT_ID('dbo.myordersid') is not null drop table dbo.myordersid
go
select isnull(orderid, 0) as orderid, empid, orderdate, shipperid
into dbo.myordersid
from Sales.Orders;
go

select * from dbo.myordersid;

-- criando um coluna com identity
--img03
select 
    IDENTITY(int, 1,1) as newcol,
    empid, 
    orderdate,
    shipperid
into dbo.colidt
from sales.orders;
go

select * from dbo.colidt;
go

if object_id('dbo.colidt') is not null drop table dbo.colidt;
go
-- se for necessário a ordem
--img04
create table dbo.colidt (
    colid int IDENTITY(1,1) not null,
    empid int,
    orderdate date,
    shipperid int);
GO
insert dbo.colidt (empid, orderdate, shipperid)
select empid, orderdate, shipperid
from sales.Orders;

select * from dbo.colidt;

--img05
-- o problema do select into é o lock na tabela
-- ele não bloqueia só a tabela, mas os schemas.
if object_id('dbo.myorders') is not null drop table dbo.myorders;
go

begin tran
select orderid, custid, empid, shipperid, orderdate
into dbo.myorders
from Sales.orders;

--------------- SEQUENCE X IDENTITY ---------------

-- identity

select * from dbo.colidt;

--img06
-- colunas identity não podem ser atualizadas.
update dbo.colidt
set colid = 0
OUTPUT
    deleted.colid,
    inserted.colid
where colid > 20 and colid <=30;

-- sequence

-- objeto criado no SQL Server
if object_id('seq.seqteste') is not null drop sequence seq.seqteste;
GO

--create schema seq;
go
create  sequence seq.seqteste as int
start with 1
increment by 1
minvalue 1
maxvalue 100
cycle
cache 10

alter sequence seq.seqteste 
restart with 1
increment by 1
minvalue 1
no maxvalue
cycle
cache 10000
select next value for seq.seqteste;

-- testando sequence

if object_id('dbo.myorders') is not null drop table dbo.myorders;
go

select 
    isnull(orderid, 0) as orderid,
    empid,
    custid,
    shipperid,
    orderdate
into dbo.myorders
from Sales.Orders
where empid = 1;
go

alter table dbo.myorders add CONSTRAINT pk_myorder primary key (orderid);
go
select * from dbo.myorders;
go

update dbo.myorders
set orderid = next value for seq.seqteste;
go

update dbo.myorders
set empid = next value for seq.seqteste;

select * from dbo.myorders;

-- preservando a ordem da tabela fonte
truncate table dbo.myorders;
go

insert into dbo.myorders(orderid, empid, custid, orderdate, shipperid)
select 
    next value for seq.seqteste over(order by orderid) as orderid,
    empid,
    custid,
    orderdate,
    shipperid
from Sales.Orders
where empid = 2;
go

select * from dbo.myorders

select * from Sales.Orders
where empid = 2;

--------------- DATA MANIPULATION: DELETE, TRUNCATE & UPDATE ---------------

drop table if exists dbo.truncatetb;
go

select 
    empid,
    custid,
    orderdate
into dbo.truncatetb
from sales.orders;
go

select * from dbo.truncatetb;
go

begin tran
truncate table dbo.truncatetb

rollback;
go
select * from dbo.truncatetb;
go

begin tran
delete from dbo.truncatetb
output
    deleted.orderdate,
    deleted.custid,
    deleted.empid
where orderdate > '20200101' and orderdate <= '20201231'

rollback;

select * from dbo.truncatetb
where orderdate  <= '20201231'
go

-- resetando a propriedade do identity

if object_id('dbo.testeid') is not null drop table dbo.testeid;
GO
create table dbo.testeid(

    id int identity,
    todaydt date default getdate(),
    texto varchar(5)
)
go

insert into dbo.testeid (texto)
values ('aaaa');
go 10

select * from dbo.testeid;
go

-- ao final dess transação, o próximo insert deve começar com 4
-- o que ela tá fazendo é armazenar o último valor do insert em uma variável e recomeçar a contagem daí
if exists (select * from dbo.testeid)
begin
    begin tran
        declare @tempval as int = (Select top(1) id from dbo.testeid with (tablockx));
        declare @reseed as int = ident_current(N'dbo.testeid') +1;
        truncate table dbo.testeid
        dbcc checkident(N'dbo.testeid', reseed, @reseed);
        print('identity reseed to ' + cast(@reseed as varchar(10)))

    commit
end
else
    print('table empty. No need to reseed')

insert into dbo.testeid(texto)
values ('bbb');
go 10


select * from dbo.testeid;
go


-- outra opção seria utilizar a funcao max retornando o maior valor da coluna id
if exists(select * from dbo.testeid)
begin
    begin tran
        declare @newid as int = (select top(1) id from dbo.testeid with (tablockx));
        declare @reseed as int = (select max(id) from dbo.testeid) + 1;
        truncate table dbo.testeid
        dbcc checkident(N'dbo.testeid', reseed, @reseed);
        print('identity reseed to ' + cast(@reseed as varchar(10)))
    commit
end
else 
    print('Table empty');
GO
insert into dbo.testeid(texto)
values('ccc');
go 5

select * from dbo.testeid;
GO
         
-- deletando linhas duplicadas.
drop table if exists dbo.duptable;
go

select orderdate, orderid, empid, custid, freight
into dbo.duptable
from Sales.Orders
    cross join
        dbo.Nums
where n <= 10000;
go

select count(*) from dbo.duptable
where orderid = 10248
go

-- delete mesmo aplicado me uma CTE deleta na tabela fonte.
-- como a cte é apenas uma 'virtualização' da tabela original, o comando acaba atuando na original.
-- por outro lado, abrir begin tran com cte acusa erro
begin tran
with delcte as (

    select orderdate, orderid
    from dbo.duptable
    where orderdate <= '20201231'
)

delete delcte
output
    deleted. orderdate,
    deleted.orderid


-- delete com output
begin TRAN
delete from dbo.duptable
output
    deleted.custid,
    deleted.empid
where orderdate <= '20201231'
rollback;

-- porém, CTE é útil quando utilizada para deletar duplicatas

with deldup as (

    select *, 
    ROW_NUMBER() over(partition by orderid
                        order by orderid
                        ) as rnw
    from dbo.duptable
)

delete from deldup
output
deleted.orderdate,
deleted.orderid,
deleted.empid,
deleted.custid,
deleted.freight
where rnw <> 1

select * from duptable;

with dropdup as (

    select *,
        row_number() over(partition by orderid
                            order by (select null)) as rnw -- ordem arbitrária, não importa a ordem do delete)
    from dbo.duptable
)
delete from dropdup
output
deleted.*
where rnw > 1;
go

begin tran
truncate table dbo.duptable

rollback;

-- delete com looping de contagem de linhas
while 1 = 1 -- cria um loop infinito
BEGIN
with countdelete as (

    select *,
        row_number() over (partition by orderid
                            order by (select null)) as rnw -- ordem arbitrária
    from dbo.duptable
)

delete top(5000) from countdelete
where rnw <> 1;

if @@ROWCOUNT < 5000 break;
end

select * from dbo.duptable;
go


-- novo teste com remoção de duplicatas

-- criando dados duplicados

select 
    empid, custid, orderdate, orderid
into dbo.newduplicate
from Sales.Orders
cross join
    dbo.Nums
where n <= 20000

select count(*) from dbo.newduplicate

select *
into tempdup
from newduplicate
where ROW_NUMBER() over (partition by orderid
                            order by (select null)) <> 1;
GO
-- como as WF são executadas durante o SELECT, ela precisa ser pré-computada com uma CTE ou TEMP
select * from tempdup;
go

select *,
    row_number() over (partition by orderid
                        order by (select null)) as rnw
into #tbtempdup
from dbo.newduplicate

begin tran
delete from #tbtempdup
output
    deleted.custid,
    deleted.orderid,
    deleted.rnw
where rnw <> 1;
ROLLBACK

with stagedup as (

    select *,
        row_number() over (partition by orderid) as rwn
    from dbo.newduplicate
)
select * 
into dbo.salesnodup
from stagedup
where rwn = 1;
GO


----------- UPDATE -----------

use tempdb;
go

if object_id('dbo.tempcust') is not null drop table dbo.tempcust;
go

select 
    identity(int, 1, 1) as custkey,
    isnull(custid,0) as custid, -- ignora o identity
    companyname, 
    country, 
    region
into dbo.tempcust
from TSQLV6.Sales.Customers;
GO

select * from dbo.tempcust;
go

if object_id('dbo.stagecust') is not null drop table dbo.stagecust;
go

select 
    identity(int, 1, 1) as custkey,
    isnull(custid, 0) as custid,
    companyname,
    country,
    region
into dbo.stagecust
from TSQLV6.sales.Customers;

select * from dbo.stagecust;
go

update dbo.stagecust
set region = 'not available'
output
    deleted.region,
    inserted.region
where region is null;

with upd_cte as (

    select 
        src.custkey as src_custkey,
        src.custid as src_custid,
        src.region as src_region,
        tgt.custkey as tgt_custkey,
        tgt.custid as tgt_custid,
        tgt.region as tgt_region
    from dbo.tempcust as tgt
        inner join
        dbo.stagecust as src
    on tgt.custkey = src.custkey
)

update upd_cte
set tgt_region = src_region
OUTPUT
    deleted.tgt_region,
    inserted.tgt_region
where tgt_region is null

select * from dbo.tempcust
where region is null;

select count(*) 
from dbo.tempcust
where region is null;

-- atualizando com views
if object_id ('dbo.vw_stagecust') is not null drop view dbo.vw_stagecust;
go

create or alter view dbo.vw_stagecust as

select 
    stg.custkey as stg_custkey,
    stg.companyname as stg_compname,
    case 
        when stg.region is null then 'not av'
        else stg.region
    end as stg_region,
    tgt.custkey as tgt_custkey,
    tgt.companyname as tgt_compname,
    tgt.region as tgt_region
from dbo.stagecust as stg
    inner join
    dbo.tempcust as tgt
on stg.custkey = tgt.custkey;
go

select * from dbo.vw_stagecust;

begin TRAN
update dbo.vw_stagecust
set tgt_region = stg_region
output
    deleted.tgt_region,
    inserted.tgt_region
where tgt_region is null
commit;
go

select * from dbo.tempcust;
go
select * from dbo.stagecust

drop view dbo.vw_stagecust;
go