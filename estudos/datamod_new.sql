USE TSQLV6;
GO

set nocount on;


--img01
if object_id ('tmp.myorders') is not null drop table tmp.myorders;
go

select orderid, 
		custid, 
		cast(empid as bigint) as empid, 
		orderdate, 
		shipperid

into tmp.myorders
from sales.orders;
go

select top(5) * from tmp.myorders;
GO

--img02
-- excluindo a propriedade identity da coluna
if OBJECT_ID('tmp.myordersid') is not null drop table tmp.myordersid
go
select 
	isnull(orderid, 0) as tmporderid, -- isnull ou coalesce retiram o identity
	empid, 
	orderdate, 
	shipperid
into tmp.myordersid
from Sales.Orders;
go

select 
	object_id,
	[name] as colname,
	is_identity
from sys.all_columns where [name] = 'tmporderid';
go

select * from tmp.myordersid;
go

select * from tmp.myordersid;
go

drop table if exists tmp.colidt;
go
-- criando um coluna com identity

select 

    IDENTITY(int, 1,1) as newcol,
    empid, 
    orderdate,
    shipperid

into tmp.colidt
from sales.orders;
go

drop table if exists tmp.ordercol;
go

select top(100)

	IDENTITY(int, 1,1) as ordercolid,
	empid,
	orderdate
into tmp.ordercol
from Sales.Orders
order by ordercolid asc;
go

select * from tmp.ordercol;
go

if object_id('tmp.colidt') is not null drop table tmp.colidt;
go
-- se for necessário a ordem

create table tmp.colidt (
    colid int IDENTITY(1,1) not null,
    empid int,
    orderdate date,
    shipperid int);
GO
insert tmp.colidt (empid, orderdate, shipperid)
select empid, orderdate, shipperid
from sales.Orders;

select * from tmp.colidt;

--img05
-- o problema do select into é o lock na tabela
-- ele não bloqueia só a tabela, mas os schemas.
if object_id('tmp.myorders') is not null drop table tmp.myorders;
go

begin tran
select orderid, custid, empid, shipperid, orderdate
into tmp.myorders
from Sales.orders;

--------------- SEQUENCE X IDENTITY ---------------

-- identity

select * from tmp.colidt;

--img06
-- colunas identity não podem ser atualizadas.
update tmp.colidt
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

if object_id('tmp.myorders') is not null drop table tmp.myorders;
go

select 
    isnull(orderid, 0) as orderid,
    empid,
    custid,
    shipperid,
    orderdate
into tmp.myorders
from Sales.Orders
where empid = 1;
go

alter table tmp.myorders add CONSTRAINT pk_myorder primary key (orderid);
go
select * from tmp.myorders;
go

update tmp.myorders
set orderid = next value for seq.seqteste;
go

update tmp.myorders
set empid = next value for seq.seqteste;

select * from tmp.myorders;

-- preservando a ordem da tabela fonte
truncate table tmp.myorders;
go

insert into tmp.myorders(orderid, empid, custid, orderdate, shipperid)
select 
    next value for seq.seqteste over(order by orderid) as orderid,
    empid,
    custid,
    orderdate,
    shipperid
from Sales.Orders
where empid = 2;
go

select * from tmp.myorders

select * from Sales.Orders
where empid = 2;

--------------- DATA MANIPULATION: DELETE, TRUNCATE & UPDATE ---------------

drop table if exists tmp.truncatetb;
go

select 
    empid,
    custid,
    orderdate
into tmp.truncatetb
from sales.orders;
go

select * from tmp.truncatetb;
go

drop table if exists #temp_truncate;
go

select 
	empid,
	custid,
	orderdate
into #temp_truncate
from Sales.Orders;
go

select * from #temp_truncate;
go

truncate table #temp_truncate;
go

begin tran
truncate table tmp.truncatetb

rollback;
go
select * from tmp.truncatetb;
go

-- cria dados duplicados
-- criei a tabela tmp.duplicate com select into
drop table if exists tmp.duplicate;

insert into tmp.duplicate
select orderdate, custid, coalesce(orderid, 0) as orderid, shipcountry
from Sales.Orders;
go 5

select * from tmp.duplicate where orderid = 10248;

-- limpa duplicate tmp.duplicate
-- cria a cte para pré filtrar  as duplicatas criando um numero para as linhas

with dedup_duplicate as (

	select
		orderdate, custid,
		orderid, shipcountry,
		ROW_NUMBER() over (partition by orderdate, custid, orderid, shipcountry
							order by orderid) as rn_dedup
	from tmp.duplicate)

delete dedup_duplicate
output
	deleted.orderdate,
	deleted.custid
where rn_dedup > 1

-- criando tabela de stage com select into

drop table if exists tmp.stagedup;
go

select *,
ROW_NUMBER() over (partition by orderdate, custid, orderid, shipcountry
					order by orderid, custid) as rn_dup
into tmp.stagedup
from tmp.duplicate;
go

select * from tmp.stagedup where orderid = 10248;

-- deletando duplicata da stage
begin tran
delete tmp.stagedup
output
	deleted.orderdate,
	deleted.custid,
	deleted.rn_dup
where rn_dup > 1;

commit;

select * from tmp.stagedup;

truncate table tmp.duplicate;
go

insert into tmp.duplicate
select orderdate, custid, orderid, shipcountry
from tmp.stagedup;
go

select * from tmp.duplicate;
go
begin tran

begin tran
delete from tmp.duplicate
output
    deleted.orderdate,
    deleted.custid,
    deleted.empid
where orderdate > '20200101' and orderdate <= '20201231'

rollback;

select * from tmp.truncatetb
where orderdate  <= '20201231'
go

-- resetando a propriedade do identity

if object_id('tmp.testeid') is not null drop table tmp.testeid;
GO
create table tmp.testeid(

    id int identity,
    todaydt date default getdate(),
    texto varchar(5)
)
go

insert into tmp.testeid (texto)
values ('aaaa');
go 10

select * from tmp.testeid;
go

-- ao final dess transação, o próximo insert deve começar com 4
-- o que ela tá fazendo é armazenar o último valor do insert em uma variável e recomeçar a contagem daí
if exists (select * from tmp.testeid)
begin
    begin tran
        declare @tempval as int = (Select top(1) id from tmp.testeid with (tablockx));
        declare @reseed as int = ident_current(N'tmp.testeid') +1;
        truncate table tmp.testeid
        dbcc checkident(N'tmp.testeid', reseed, @reseed);
        print('identity reseed to ' + cast(@reseed as varchar(10)))

    commit
end
else
    print('table empty. No need to reseed')

insert into tmp.testeid(texto)
values ('bbb');
go 10


select * from tmp.testeid;
go


-- outra opção seria utilizar a funcao max retornando o maior valor da coluna id
if exists(select * from tmp.testeid)
begin
    begin tran
        declare @newid as int = (select top(1) id from tmp.testeid with (tablockx));
        declare @reseed as int = (select max(id) from tmp.testeid) + 1;
        truncate table tmp.testeid
        dbcc checkident(N'tmp.testeid', reseed, @reseed);
        print('identity reseed to ' + cast(@reseed as varchar(10)))
    commit
end
else 
    print('Table empty');
GO
insert into tmp.testeid(texto)
values('ccc');
go 5

select * from tmp.testeid;
GO
         
-- deletando linhas duplicadas.
drop table if exists tmp.duptable;
go

select orderdate, orderid, empid, custid, freight
into tmp.duptable
from Sales.Orders
    cross join
        tmp.Nums
where n <= 10000;
go

select count(*) from tmp.duptable
where orderid = 10248
go

-- delete mesmo aplicado me uma CTE deleta na tabela fonte.
-- como a cte é apenas uma 'virtualização' da tabela original, o comando acaba atuando na original.
-- por outro lado, abrir begin tran com cte acusa erro
begin tran
with delcte as (

    select orderdate, orderid
    from tmp.duptable
    where orderdate <= '20201231'
)

delete delcte
output
    deleted. orderdate,
    deleted.orderid


-- delete com output
begin TRAN
delete from tmp.duptable
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
    from tmp.duptable
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
    from tmp.duptable
)
delete from dropdup
output
deleted.*
where rnw > 1;
go

begin tran
truncate table tmp.duptable

rollback;

-- criar carga de dados duplicados
-- cada zero adicionado multiplicar por 830 --> 830 x 1000

drop table if exists tmp.batchdelete;
go
select 
	empid,
	custid,
	orderdate,
	shipcountry
into tmp.batchdelete
from sales.orders
	cross join
	dbo.nums
where n <= 10000;
go

with into_nodup as (

	select 
		empid, custid,
		orderdate, shipcountry,
		row_number() over (partition by empid, custid, orderdate
							order by custid, empid) as dup_rnw
	from tmp.batchdelete
)

select empid, custid, orderdate, shipcountry
into nodup_stg
from into_nodup
where dup_rnw = 1;
go

select * from nodup_stg;

-- truncate batchdelete

truncate table tmp.batchdelete;

-- carga batchdelete

insert into tmp.batchdelete
select * from nodup_stg;

select * from tmp.batchdelete;

-- deletando com looping em lotes de linhas
begin tran
while 1=1
	begin
			with batchdel as(

			select *, 
				row_number() over (partition by empid, custid, 
												orderdate, shipcountry
									order by custid) as batch_rwn
			from tmp.batchdelete
			)
		delete top(10000)
		from batchdel
		output
			deleted.empid,
			deleted.custid,
			deleted.batch_rwn
		where batch_rwn > 1

		if @@rowcount < 10000 break;
	end

rollback;

select * from tmp.batchdelete;
go

-- delete com looping de contagem de linhas
while 1 = 1 -- cria um loop infinito
BEGIN
with countdelete as (

    select *,
        row_number() over (partition by orderid
                            order by (select null)) as rnw -- ordem arbitrária
    from tmp.duptable
)

delete top(5000) from countdelete
where rnw <> 1;

if @@ROWCOUNT < 5000 break;
end

select * from tmp.duptable;
go


-- novo teste com remoção de duplicatas

-- criando dados duplicados

select 
    empid, custid, orderdate, orderid
into tmp.newduplicate
from Sales.Orders
cross join
    tmp.Nums
where n <= 20000

select count(*) from tmp.newduplicate

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
from tmp.newduplicate

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
    from tmp.newduplicate
)
select * 
into tmp.salesnodup
from stagedup
where rwn = 1;
GO

--- HINTS COM DELETE

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

begin tran
	delete tmp.batchdelete
	output
		deleted.*
	where empid in (1, 2, 4)

rollback;

----------- UPDATE -----------

use tempdb;
go

if object_id('tmp.tempcust') is not null drop table tmp.tempcust;
go

select 
    identity(int, 1, 1) as custkey,
    isnull(custid,0) as custid, -- ignora o identity
    companyname, 
    country, 
    region
into tmp.tempcust
from TSQLV6.Sales.Customers;
GO

select * from tmp.tempcust;
go

if object_id('tmp.stagecust') is not null drop table tmp.stagecust;
go

select 
    identity(int, 1, 1) as custkey,
    isnull(custid, 0) as custid,
    companyname,
    country,
    region
into tmp.stagecust
from TSQLV6.sales.Customers;

select * from tmp.stagecust;
go

update tmp.stagecust
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
    from tmp.tempcust as tgt
        inner join
        tmp.stagecust as src
    on tgt.custkey = src.custkey
)

update upd_cte
set tgt_region = src_region
OUTPUT
    deleted.tgt_region,
    inserted.tgt_region
where tgt_region is null

select * from tmp.tempcust
where region is null;

select count(*) 
from tmp.tempcust
where region is null;

-- atualizando com views
if object_id ('tmp.vw_stagecust') is not null drop view tmp.vw_stagecust;
go

create or alter view tmp.vw_stagecust as

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
from tmp.stagecust as stg
    inner join
    tmp.tempcust as tgt
on stg.custkey = tgt.custkey;
go

select * from tmp.vw_stagecust;

begin TRAN
update tmp.vw_stagecust
set tgt_region = stg_region
output
    deleted.tgt_region,
    inserted.tgt_region
where tgt_region is null
commit;
go

select * from tmp.tempcust;
go
select * from tmp.stagecust

drop view tmp.vw_stagecust;
go

drop table if exists tmp.temproduct;
go

select
    productid,
    productname,
    unitprice
into tmp.temproduct
from production.products
go

select * from tmp.temproduct;

with update_prod as (

    select * from tmp.temproduct
)

update update_prod
set unitprice = unitprice + unitprice * 0.2
output
deleted.unitprice,
inserted.unitprice
where unitprice < 18.00

select * from tmp.temproduct
where unitprice < 18;
go

begin tran
update tmp.temproduct
set unitprice = pp.unitprice
output
deleted.unitprice,
inserted.productid,
inserted.unitprice
from tmp.temproduct as tp
inner join
production.products as pp
on tp.productid = pp.productid
where tp.unitprice <> pp.unitprice;
commit;

select * from tmp.temproduct;

-- UPDATE COM VARIÁVEIS

-- eliminando gaps em sequences e identity utilizando tabela de apoio

use tempdb;
go

if object_id(N'tmp.mysequence') is not null drop table tmp.mysequence;
go

create table tmp.mysequence(

    id int not null
);
GO
insert into tmp.mysequence(id)
values (0);
go

select * from tmp.mysequence;
go

-- agora com a tabela de apoio criada no tempdb, basta armazenar esse valor em uma variável
declare @newid as int;
update tmp.mysequence
set @newid = id += 1;
GO

select * from tmp.mysequence;
go

-- teste para dw
if object_id(N'tmp.testetable') is not null drop table tmp.testetable;
go

create  table tmp.testetable(

    nome varchar(10),
    id int
);

insert tmp.testetable (nome, id)
values ('aaa', Cast(rand(checksum(newid()))*10 as int))
go 10

declare @idteste as int;
set @idteste = 0;

update tmp.testetable
set id = @idteste + 1;

select * from tmp.testetable;

declare @valid as int = 0;
select @valid;

while @valid <= 11
begin
    update tmp.testetable
    set id = @valid + 1
end

declare @tempid as int = (select min(id) from tmp.testetable);
declare @maxtempid as int = (select distinct(count(*)) from tmp.testetable)
while @tempid <= @maxtempid
begin
    begin tran
        update tmp.testetable
        set id = @tempid + 1
set @tempid += 1
end

rollback
go

select * from tmp.testetable;
select distinct(count(*)) from tmp.testetable;

begin tran
update tmp.testetable
set id = (select min(id) + 1 from tmp.testetable)
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
    from tmp.testetable
    )

update ct
set id = rwn
output
    deleted.id,
    inserted.id

select * from tmp.testetable;


-- outra forma seria criando uma tabela temporária e realizar um join
if object_id('tmp.gapidentity') is not null drop table tmp.gapidentity;
GO

create table tmp.gapidentity (

    id int not null,
    letter varchar(5) not null
);
go

insert into tmp.gapidentity
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

if object_id('tmp.tempidentity') is not null drop table tmp.tempidentity;
go
create table tmp.tempidentity(

    id int not null,
    letter varchar(5) not null
);
go

insert into tmp.tempidentity
select id, letter
from tmp.gapidentity;
go

select * from tmp.tempidentity;
go

with seqidentity as (

    select 
        id,
        letter,
        ROW_NUMBER() over (order by (select null)) as rn
    from tmp.tempidentity
)
update tmp.gapidentity 
set id = rn
from seqidentity as sq
inner join
tmp.gapidentity as gpi
on gpi.id = sq.id

select * from tmp.gapidentity;
go

-- utilizando temp table
-- faça um select into com rownumber e atualize a partir disso
-- ainda garante o determinismo da query utilizando order by fora da WF

drop table if exists ##tempid;
go
select *,
row_number() over (order by (select null)) as rn 
into ##tempid
from tmp.gapidentity
order by rn;
GO

select * from ##tempid;

begin tran
update tmp.gapidentity
set id = rn
output
    deleted.id,
    inserted.id
from ##tempid as tid
inner join
tmp.gapidentity as gpi
on tid.id = gpi.id
commit;

select * from tmp.gapidentity;
go


-------------------------- MERGE --------------------------
if object_id('tmp.stagecust') is not null drop table tmp.stagecust;
go

select *
into tmp.stagecust
from sales.customers;
GO

-- comando merge

merge into  tmp.stagecust as tgt
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

merge into tmp.stagecust as tgt
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

merge into tmp.stagecust as st
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

select * from tmp.stagecust;

select * from sales.customers;
go

if object_id(N'mergetable') is not null drop table tmp.mergetable;
go

SELECT
    identity(int, 1, 1) as custkey,
    coalesce(custid, 0) as custid,
    companyname,
    contacttitle,
    city,
    country,
    case
        when contacttitle like 'owner' then 'update'
        when contacttitle like '%representative' then 'delete'
        else 'No action'
    end as flag
into tmp.mergetable
from tmp.stagecust

select * from mergetable;
go

merge into tmp.mergetable as mgt
using tmp.stagecust as sc
on sc.custid = mgt.custid

when matched and flag = 'update'
then 
update set 
    mgt.contacttitle = sc.contacttitle, 
    mgt.flag = 'updated'
when matched and flag = 'delete'
then 
    delete;

select * from tmp.mergetable;

-- UTILIZANDO EXCEPT
-- ALTERNATIVA PARA EXCLUIR UMA DETERMINADA CONDIÇÃO

select top(5) * from mergetable;

select top(5) * from tmp.stagecust;

begin tran
merge into tmp.mergetable as tgt
using tmp.stagecust as src
on tgt.custid = src.custid
when matched and exists (select tgt.city except select src.city where src.city like 'mexico%') 
then
update set 
    tgt.city = 'not city'

when not matched by source then 
delete;

rollback
select * from mergetable;

alter table mergetable
add isactual varchar(5);

alter table mergetable
add custkey int identity(1,1)

begin tran
merge into tmp.mergetable as tgt
using tmp.stagecust as src
on tgt.custkey = src.custkey

when matched and     
    tgt.country = src.country
    and tgt.country is not null

then update set 
    tgt.isactual = 'Yes'

when not matched then
insert (companyname, contacttitle, city, country, flag, isactual)
values (src.companyname, src.contacttitle, src.city, src.country, 'updated', 'yes');
rollback;

select * from tmp.mergetable;

select * from stagecust;


select count(country), country
from tmp.mergetable
group by country;

update tmp.mergetable
set custid += 1
where country = 'usa' or country = 'germany'

-- FLAG SERIALIZABLE --

if object_id(N'tmp.addcustomer') is not null drop proc tmp.addcustomer;
go

create proc tmp.addcustomer 

@custid int, @companyname varchar(25), @phone varchar(20), @address varchar(50)
as

merge into tmp.customers with (serializable)  as tgt
using (values (@custid, @companyname, @phone, @address)) 
as src (custid, companyname, phone, [address])
on tgt.custid = src.custid

when matched then 
    update set
        tgt.companyname = src.companyname,
        tgt.phone = src.phone,
        tgt.[address] = src.[address]

when not matched then 
    insert (custid, companyname, phone, [address])
    values (src.custid, src.companyname, src.phone, src.[address]);
go

set nocount ON
use tempdb;
go

while 1 = 1
begin
    declare @curcustid as int = checksum(cast(sysdatetime() as datetime2(2)));
    exec tmp.addcustomer @custid = @curcustid, @companyname = 'a', @phone='b', @address = 'c';
end;


merge into tmp.customers as tgt
using sales.customers as src
on tgt.custid = src.custid
and src.custid = 2

when matched then
    update set
        tgt.companyname = src.companyname,
        tgt.phone = src.phone,
        tgt.address = src.address

when not matched then
    insert (custid, companyname, phone, [address])
    values (src.custid, src.companyname, src.phone, src.[address]);

---- OUTPUT ---

-- exemplo com identity - insert

if object_id(N'tmp.testeoutput') is not null drop table tmp.testeoutput;
go

create table tmp.testeoutput (

    keycol int identity(1,1) not null primary key clustered,
    datacol NVARCHAR(40) not null
);
go

insert tmp.testeoutput (datacol)
output 
    inserted.$identity, 
    inserted.datacol
select lastname
from HR.employees
where country = 'usa';
