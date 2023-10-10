/*
row level security
*/

select @@VERSION

--Microsoft SQL Server 2019 (RTM-CU22) (KB5027702) - 15.0.4322.2 (X64)   
--Jul 27 2023 18:11:00   Copyright (C) 2019 Microsoft Corporation  
--Developer Edition (64-bit) on Windows 10 Enterprise 10.0 <X64> (Build 19045: ) (Hypervisor) 

CREATE USER Manager WITHOUT LOGIN;		-- vede tutti gli ordini
CREATE USER SalesRep1 WITHOUT LOGIN;	-- vede gli ordini dell'empid 1
CREATE USER SalesRep2 WITHOUT LOGIN;	-- vede gli ordini dell'empid 2
GO

select top 10 * from Sales.Orders

GRANT SELECT ON Sales.Orders TO Manager;
GRANT SELECT ON Sales.Orders TO SalesRep1;
GRANT SELECT ON Sales.Orders TO SalesRep2;
GO

CREATE SCHEMA Security;
GO
  
alter FUNCTION Security.tf_securitypredicate(@SalesRep AS nvarchar(50))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN 
	
	SELECT 1 AS tf_securitypredicate_result
	WHERE @SalesRep = right(USER_NAME(),1) OR USER_NAME() = 'Manager';
GO



CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.tf_securitypredicate(empid)
ON Sales.Orders
WITH (STATE = ON);
GO

GRANT SELECT ON Security.tf_securitypredicate TO Manager;
GRANT SELECT ON Security.tf_securitypredicate TO SalesRep1;
GRANT SELECT ON Security.tf_securitypredicate TO SalesRep2;


select * from Security.tf_securitypredicate(1)


EXECUTE AS USER = 'SalesRep1';
select USER_NAME()
SELECT * FROM Sales.Orders;
REVERT;
  
EXECUTE AS USER = 'SalesRep2';
SELECT * FROM Sales.Orders;
REVERT;
  
EXECUTE AS USER = 'Manager';
SELECT * FROM Sales.Orders;
REVERT;

select * 
from sys.objects
where type = 'U'


ALTER SECURITY POLICY SalesFilter
WITH (STATE = OFF);