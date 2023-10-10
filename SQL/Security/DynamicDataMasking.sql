-- Dynamic Data Masking

-- costruzione della tabella da mascherare
select *, 
	email = lower(rtrim(ltrim(firstname)) + '.' + rtrim(ltrim(lastname)) + '@contoso.it')
into  hr.employeesMasked
from hr.Employees

select * from hr.employeesMasked

ALTER TABLE hr.employeesMasked
ALTER COLUMN city ADD MASKED WITH (FUNCTION = 'partial(2,"xxxxxxxxxxxx",1)');

ALTER TABLE hr.employeesMasked
ALTER COLUMN address ADD MASKED WITH (FUNCTION = 'default()');


CREATE USER MaskingTestUser WITHOUT LOGIN;

GRANT SELECT ON SCHEMA::HR TO MaskingTestUser;
  
-- impersonate for testing:
EXECUTE AS USER = 'MaskingTestUser';  --'SalesRep1
select USER_NAME()
SELECT * FROM hr.employeesMasked;

REVERT;
select @@VERSION

-- modifico il masking già esistente
ALTER TABLE hr.employeesMasked
ALTER COLUMN city ADD MASKED WITH (FUNCTION = 'partial(2,"__test__",1)');

-- non funziona a causa del data type
ALTER TABLE hr.employeesMasked
ALTER COLUMN birthdate ADD MASKED WITH (FUNCTION = 'partial(2,"00-00-",2)');

ALTER TABLE hr.employeesMasked
ALTER COLUMN email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE hr.employeesMasked
ALTER COLUMN phone ADD MASKED WITH (FUNCTION = 'partial(0,"(XXX) XXX-",4)');

select * from hr.employeesMasked