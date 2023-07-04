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

drop table if exists dbo.temproduct;
go

select
    productid,
    productname,
    unitprice
into dbo.temproduct
from production.products
go

select * from dbo.temproduct;

with update_prod as (

    select * from dbo.temproduct
)

update update_prod
set unitprice = unitprice + unitprice * 0.2
output
deleted.unitprice,
inserted.unitprice
where unitprice < 18.00

select * from dbo.temproduct
where unitprice < 18;
go

begin tran
update dbo.temproduct
set unitprice = pp.unitprice
output
deleted.unitprice,
inserted.productid,
inserted.unitprice
from dbo.temproduct as tp
inner join
production.products as pp
on tp.productid = pp.productid
where tp.unitprice <> pp.unitprice;
commit;

select * from dbo.temproduct;

-- UPDATE COM VARIÁVEIS

-- eliminando gaps em sequences e identity utilizando tabela de apoio

use tempdb;
go

if object_id(N'dbo.mysequence') is not null drop table dbo.mysequence;
go

create table dbo.mysequence(

    id int not null
);
GO
insert into dbo.mysequence(id)
values (0);
go

select * from dbo.mysequence;
go

-- agora com a tabela de apoio criada no tempdb, basta armazenar esse valor em uma variável
declare @newid as int;
update dbo.mysequence
set @newid = id += 1;
GO

select * from dbo.mysequence;
go

-- teste para dw
if object_id(N'dbo.testetable') is not null drop table dbo.testetable;
go

create  table dbo.testetable(

    nome varchar(10),
    id int
);

insert dbo.testetable (nome, id)
values ('aaa', Cast(rand(checksum(newid()))*10 as int))
go 10

declare @idteste as int;
set @idteste = 0;

update dbo.testetable
set id = @idteste + 1;

select * from dbo.testetable;

declare @valid as int = 0;
select @valid;

while @valid <= 11
begin
    update dbo.testetable
    set id = @valid + 1
end

declare @tempid as int = (select min(id) from dbo.testetable);
declare @maxtempid as int = (select distinct(count(*)) from dbo.testetable)
while @tempid <= @maxtempid
begin
    begin tran
        update dbo.testetable
        set id = @tempid + 1
set @tempid += 1
end

rollback
go

select * from dbo.testetable;
select distinct(count(*)) from dbo.testetable;

begin tran
update dbo.testetable
set id = (select min(id) + 1 from dbo.testetable)
output
deleted.id,
inserted.id

rollback;

-- solucionando gaps com window function 
with ct as (

    select
        id,
        nome,
        ROW_NUMBER() over( order by (select null)) as rwn
    from dbo.testetable
    )

update ct
set id = rwn
output
    deleted.id,
    inserted.id

select * from dbo.testetable;


-- outra forma seria criando uma tabela temporária e realizar um join
if object_id('dbo.gapidentity') is not null drop table dbo.gapidentity;
GO

create table dbo.gapidentity (

    id int not null,
    letter varchar(5) not null
);
go

insert into dbo.gapidentity
values (1, 'aa'),
        (3, 'bb'),
        (4, 'dd'),
        (10, 'ef'),
        (6, 'ab'),
        (6, 'fd'),
        (8, 'hh'),
        (9, 'll'),
        (8, 'cd');
go

if object_id('dbo.tempidentity') is not null drop table dbo.tempidentity;
go
create table dbo.tempidentity(

    id int not null,
    letter varchar(5) not null
);
go

insert into dbo.tempidentity
select id, letter
from dbo.gapidentity;
go

select * from dbo.tempidentity;
go

with seqidentity as (

    select 
        id,
        letter,
        ROW_NUMBER() over (order by (select null)) as rn
    from dbo.tempidentity
)
update dbo.gapidentity 
set id = rn
from seqidentity as sq
inner join
dbo.gapidentity as gpi
on gpi.id = sq.id

select * from dbo.gapidentity;
go

-- utilizando temp table
-- faça um select into com rownumber e atualize a partir disso
-- ainda garante o determinismo da query utilizando order by fora da WF

drop table if exists ##tempid;
go
select *,
row_number() over (order by (select null)) as rn 
into ##tempid
from dbo.gapidentity
order by rn;
GO

select * from ##tempid;

begin tran
update dbo.gapidentity
set id = rn
output
    deleted.id,
    inserted.id
from ##tempid as tid
inner join
dbo.gapidentity as gpi
on tid.id = gpi.id
commit;

select * from dbo.gapidentity;
go


-------------------------- MERGE --------------------------
if object_id('dbo.stagecust') is not null drop table dbo.stagecust;
go

select *
into dbo.stagecust
from sales.customers;
GO

-- comando merge

merge into  dbo.stagecust as tgt
using  sales.customers as src
on tgt.custid = src.custid
when matched then 
update set 
    tgt.companyname = src.companyname,
    tgt.phone = src.phone,
    tgt.address = src.address
when not matched then
    insert ( companyname, phone, [address])
    values ( src.companyname, src.phone, src.[address])
when not matched by source then
DELETE;

--- com base em um campo

merge into dbo.stagecust as tgt
using sales.customers as src
on tgt.custid = src.custid
when matched and src.contacttitle like 'sales%' then
    delete

when not matched by source then
delete;
go

select * from stagecust;

begin tran
update stagecust
set contactname = 'aaaa'
output
    deleted.contactname,
    inserted.contactname
where contactname is not null
commit;

merge into dbo.stagecust as st
using sales.customers  as sc
on st.custid = sc.custid

when matched and
    (st.contactname <> sc.contactname
    or st.region is null) then
update set 
    st.contactname = sc.contactname,
    st.region = 'not know'

when not matched by source then
delete;
go

select * from dbo.stagecust;

select * from sales.customers;
go

if object_id(N'mergetable') is not null drop table dbo.mergetable;
go

SELECT
    custid,
    companyname,
    contacttitle,
    city,
    region
    country,
    case
        when contacttitle like 'owner' then 'update'
        when contacttitle like '%representative' then 'delete'
        else 'No action'
    end as flag
into dbo.mergetable
from dbo.stagecust

select * from mergetable;
go

merge into dbo.mergetable as mgt
using dbo.stagecust as sc
on sc.custid = mgt.custid

when matched and flag = 'update'
then 
update set 
    mgt.contacttitle = sc.contacttitle, 
    mgt.flag = 'updated'
when matched and flag = 'delete'
then 
    delete;

select * from dbo.mergetable;

-- UTILIZANDO EXCEPT
-- ALTERNATIVA PARA EXCLUIR UMA DETERMINADA CONDIÇÃO

select top(5) * from mergetable;

select top(5) * from dbo.stagecust;

begin tran
merge into dbo.mergetable as tgt
using dbo.stagecust as src
on tgt.custid = src.custid
when matched and exists (select tgt.city except select src.city where src.city like 'mexico%') 
then
update set 
    tgt.city = 'not city'

when not matched by source then 
delete;

rollback
select * from mergetable;