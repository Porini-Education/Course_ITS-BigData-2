/*
SELECT
FROM 
WHERE
GROUP BY
HAVING
ORDER BY


FROM 
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
*/


SELECT
	count(*)
FROM sales.Orders
WHERE count(*) > 10

print 'pippo'

create function dbo.test( @cliente int)	RETURNS TABLE AS
	RETURN
		select 
			*
		from sales.Orders
		WHERE custid = @cliente

select * from dbo.test(1)
go

WITH cteA AS
(
	SELECT CAST( '20100101' AS date) as Data
	union all
	SELECT DATEADD(DAY, 1 , Data) 
		FROM cteA 
		WHERE DATEADD(DAY, 1 , Data) <= getdate()
)

select * from ctea

with ctea as 
(
	SELECT DATEADD(DAY, n-1 , '20100101') as Data
	FROM dbo.Nums
	where DATEADD(DAY, n-1 , '20100101') <= GETDATE()
)

select *, year(data)
from ctea


-- table function che restituisce gli n ordini più recenti di un dato cliente
CREATE FUNCTION dbo.TOPNOrders ( @n int, @cliente int) RETURNS TABLE 
AS RETURN
	SELECT TOP (@n)
		*
	FROM Sales.Orders
	WHERE custid = @cliente
	ORDER BY orderdate DESC

select * from dbo.TOPNOrders(2, 1)

-- per ogni cliente mostrare i 2 ordini più recenti


select C.custid, count(*)--, T.*
from sales.Customers C
	CROSS APPLY dbo.TOPNOrders (2, C.custid) T
GROUP BY C.custid
HAVING count(*) = 1



-- window function
WITH CTEA AS (
SELECT
	orderid, orderdate, custid, freight,
	sum(freight) over ( partition by custid ) as SommaCliente,
	sum(freight) over ( order by orderdate ) as SommaCumulata,
	sum(freight) over ( partition by custid order by orderdate ) as SommaCumulataCliente,
	-- importanza del cliente
	sum(freight) over ( partition by custid ) / sum(freight) OVER () * 100 as IncidenzaCliente
FROM sales.Orders
where sum(freight) over ( order by orderdate ) > 10
)

select distinct 
	custid, IncidenzaCliente
from CTEA
order by 2 desc


select n, char(n-1), nchar(n-1)
from dbo.Nums



select *
from sales.Customers inner join sales.Orders
	on customers.custid = Orders.custid

select *
from sales.Customers left outer join sales.Orders
	on customers.custid = Orders.custid
where orderid is null



begin tran


select @@TRANCOUNT

commit
rollback