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
