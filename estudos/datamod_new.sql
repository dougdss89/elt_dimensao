set nocount on;

--img01
if object_id ('dbo.myorders') is not null drop table dbo.myorders;
go

select orderid, custid, empid, orderdate, shipperid
into dbo.myorders
from sales.orders;
go

select * from dbo.myorders;


