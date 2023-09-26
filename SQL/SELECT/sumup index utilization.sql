SELECT custid, sum(freight)
FROM sales.orders
where custid = 14
group by custid

-- execution plan

select orderdate
from sales.Orders
where orderdate between '20010101' and '20141231'

select orderdate
from sales.Orders
where orderdate like '2014%'

select orderdate
from sales.Orders
where year(orderdate) = 2014


select *
from sales.Orders
