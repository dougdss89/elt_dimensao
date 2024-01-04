use AdventureWorks2019;
-- is null para retornar na consulta apenas os valores nulos
select 
    BusinessEntityID,
    LastName,
    title
from Person.Person
where title is null;

-- falha ao igualar com null
select 
    BusinessEntityID,
    lastname,
    title 
from person.person
where title = null;

select salesorderid, customerid , salespersonid
from sales.salesorderheader
where salespersonid is null

-- teste com funções de agregação
-- falha na agregação
select customerid, salespersonid
from sales.salesorderheader
where salespersonid is not null;

select count(salespersonid), salespersonid
from sales.salesorderheader
group by salespersonid

-- mesmo utilizando window functions, ele conta apenas o total de vendas feitas por "vendedores"
-- há a exclusão das vendas cujo o salespersonid é nulo
select 
    customerid,
    count(salespersonid) over () as salesp_count
from sales.salesorderheader

-- demonstrando que se "alterar" o valor de null para um integer, por exemplo, o count funciona, mas somente naquela operação
-- na coluna salespersonid, o valor continua NULL.
select  
    customerid,
    count(coalesce(salespersonid, 0)) over() as salesp_countnull,
    salespersonid
from sales.salesorderheader
where salespersonid is null;

-- existe diferença entre count(*) e count(column)?
-- sim, no primeiro, ele não ignora nulls. Na coluna explícita, sim.
-- tanto count(*) quanto count(coalesce(column, 0)) retornam o mesmo resultado, já que estamos substituindo por um valor conhecido.
select 
    count(*) as count_star,
    count(salespersonid) as salesp_count,
    count(coalesce(salespersonid, 0)) as count_sales
from sales.salesorderheader;

-- É possível anular um  valor caso ele seja encontrado.
-- É como se utilizássemos o coalesce ao contrário. 
select 
    customerid,
    salespersonid,
    nullif(salespersonid, 290) as null_salesperson
from sales.salesorderheader
where salespersonid is not null and salespersonid = 290;
go

-- anulando com joins
-- assim, se houver nas duas tabelas, a coluna é anulada.
select
    t1.productid as prod,
    t2.productid as salesprod,
    nullif(t1.productid, t2.productid) as null_product
from production.product as t1
    left join   
     sales.salesorderdetail as t2
on t1.productid = t2.productid;


-- erro em funções de agregação como sum e avg
-- essas funções irão ignorar os valores nulos
-- existe até um warning do próprio banco informando
if OBJECT_ID(N'null_table') is not null drop table #null_table;
go

create table #null_table (
	id int,
	idnum int);
go

insert into #null_table 
values(null, null)
go 5

select 
	sum(id),
	avg(id) as avgid
from #null_table;

/*
count(*) considera nulls pois ele conta apenas a quantidade de linhas criadas.
já count(column) precisa validar as linhas quando está contando. Então, quando se depara com NULL, não consegue validar e exclui.
*/

