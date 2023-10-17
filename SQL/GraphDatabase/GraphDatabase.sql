CREATE SCHEMA its

CREATE TABLE its.Person (
	id int identity,
	Name varchar(15),
	Surname varchar(15),
	FullName as concat(Surname, ' ', Name)
) as NODE

insert into its.Person 
	select Name, REVERSE(name) as Surname from dbo.person
		where id = 10

select * 
from its.Person

delete from its.Person where id = 10

-- proviamo ad srotolare il JSON
select 
	JSON_VALUE($node_id,'$.id') as Id
	,JSON_VALUE($node_id,'$.type') as   [type]
	,JSON_VALUE($node_id,'$.schema') as [schema]
	,JSON_VALUE($node_id,'$.table') as  [table]
from its.Person

select [graph_id_CFE32879FA7F4CABBF61A3ED51F0C95C]
from [its].[Person]

CREATE TABLE its.Follows 
( [Value] tinyint DEFAULT(1) )
as EDGE

SELECT * FROM its.Follows

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name = 'Alfa'),(select $node_id from its.Person 
								where Name = 'Delta'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name = 'Alfa'),(select $node_id from its.Person 
								where Name = 'Echo'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name = 'Bravo'),(select $node_id from its.Person 
								where Name = 'Fox'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name = 'Bravo'),(select $node_id from its.Person 
								where Name = 'Golf'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'C%'),(select $node_id from its.Person 
								where Name like 'A%'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'C%'),(select $node_id from its.Person 
								where Name like 'D%'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'C%'),(select $node_id from its.Person 
								where Name like 'H%'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'D%'),(select $node_id from its.Person 
								where Name like 'J%')),
((select $node_id from its.Person 
	where Name like 'D%'),(select $node_id from its.Person 
								where Name like 'G%'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'E%'),(select $node_id from its.Person 
								where Name like 'D%'))
,((select $node_id from its.Person 
	where Name like 'E%'),(select $node_id from its.Person 
								where Name like 'B%'))
,((select $node_id from its.Person 
	where Name like 'E%'),(select $node_id from its.Person 
								where Name like 'H%'))


INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'F%'),(select $node_id from its.Person 
								where Name like 'H%'))
,((select $node_id from its.Person 
	where Name like 'F%'),(select $node_id from its.Person 
								where Name like 'E%'))
,((select $node_id from its.Person 
	where Name like 'F%'),(select $node_id from its.Person 
								where Name like 'D%'))

INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'G%'),(select $node_id from its.Person 
								where Name like 'F%'))


INSERT INTO its.Follows($from_id, $to_id) values
((select $node_id from its.Person 
	where Name like 'H%'),(select $node_id from its.Person 
								where Name like 'G%'))
,((select $node_id from its.Person 
	where Name like 'H%'),(select $node_id from its.Person 
								where Name like 'B%'))
,((select $node_id from its.Person 
	where Name like 'I%'),(select $node_id from its.Person 
								where Name like 'J%'))
,((select $node_id from its.Person 
	where Name like 'I%'),(select $node_id from its.Person 
								where Name like 'A%'))
,((select $node_id from its.Person 
	where Name like 'J%'),(select $node_id from its.Person 
								where Name like 'C%'))
,((select $node_id from its.Person 
	where Name like 'J%'),(select $node_id from its.Person 
								where Name like 'G%'))

SELECT * FROM its.Follows


select Person.Name + ' -> ' + FollowedPerson.Name + ' -> ' + FollowedPerson2.Name
from 
	its.Person
	,its.Follows					-- 22 rows
	,its.Person as FollowedPerson	-- 10 rows
	,its.Follows as Follows2
	,its.Person as FollowedPerson2
where 1=1
	--and FollowedPerson.Name = 'Alfa'
	and MATCH(Person -(Follows)-> FollowedPerson AND FollowedPerson -(Follows2)-> FollowedPerson2)
ORDER BY 
	Person.Name , FollowedPerson.Name , FollowedPerson2.Name

select * from 
(select 
	Person.Name
	,STRING_AGG( FollowedPerson.Name, ' -> ' ) WITHIN GROUP (GRAPH PATH) as FollowedPeople
	,LAST_VALUE( FollowedPerson.Name ) WITHIN GROUP (GRAPH PATH) as LastPerson
	,count(FollowedPerson.Name) WITHIN GROUP (GRAPH PATH) as Level
from 
	its.Person as Person
	,its.Follows for path as Follows	
	,its.Person for path as FollowedPerson
where 1=1
	--and Person.Name = 'Alfa'
	and MATCH(SHORTEST_PATH(Person (-(Follows)-> FollowedPerson){1,3}))
	) as T
where t.LastPerson = 'Alfa'
	and t.name <> 'Alfa'
	--and t.level <= 3