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