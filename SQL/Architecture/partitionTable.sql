CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))  
    AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01') ;  
GO  

CREATE PARTITION SCHEME myRangePS1  
    AS PARTITION myRangePF1  
    ALL TO ('PRIMARY') ;  
GO  

CREATE TABLE dbo.PartitionTable (col1 datetime2(0) PRIMARY KEY, col2 char(10))  
    ON myRangePS1 (col1) ;  
GO


insert into dbo.PartitionTable(col1) values
 ('2022-03-15')
,('2022-04-01')
,('2022-04-15')
,('2022-05-01')
,('2022-05-15')
,('2022-06-01')
,('2022-06-15')

select * 
from dbo.PartitionTable

select *, object_name(object_id)
from sys.partitions
where object_name(object_id) = 'PartitionTable'
order by 1

insert into dbo.PartitionTable(col1) values
 ('2022-07-16')


select *
from sys.partition_range_values prv
	inner join sys.partition_functions pf		on  prv.function_id = pf.function_id
	inner join sys.partition_schemes ps			on pf.function_id = ps.function_id
where object_name(object_id) = 'PartitionTable'


SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, *   
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
JOIN sys.partition_schemes ps   
    ON i.data_space_id = ps.data_space_id   
WHERE t.name = 'PartitionTable';   
GO  


select 
    object_schema_name(i.object_id) as [schema],
    object_name(i.object_id) as [object_name],
    t.name as [table_name],
    i.name as [index_name],
    s.name as [partition_scheme]
from sys.indexes i
    join sys.partition_schemes s on i.data_space_id = s.data_space_id
    join sys.tables t on i.object_id = t.object_id 


-- aggiungiamo un nuovo valore alla partition function '2022-07-01'
alter PARTITION FUNCTION myRangePF1 ()
	split range ('2022-07-01');  
GO  

-- verifichiamo quanti partizionamenti abbiamo e quante righe ci sono dentro
select *, object_name(object_id)
from sys.partitions
where object_name(object_id) = 'PartitionTable'
order by 1

-- cancello il valore appena inserito nella partition function
alter PARTITION FUNCTION myRangePF1 ()
	merge range ('2022-07-01');  
GO

select *, object_name(object_id)
from sys.partitions
where object_name(object_id) = 'PartitionTable'
order by 1