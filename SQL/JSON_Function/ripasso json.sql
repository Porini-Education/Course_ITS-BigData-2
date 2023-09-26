--declare @j nvarchar(max) = '{
--	"id" : 1,
--	"colore" : "verde",
--	"animali" :  [
--		{
--			"nome" : "birillo",
--			"specie" : "gatto"
--		},
--		{
--			"nome" : "azzurro",
--			"specie" : "pesce"
--		}
--	]
--}'

-- idJson, colore, AnimaleNome, AnimaleSpecie

--select @j, isjson(@j), 
--	JSON_VALUE(@j, '$.colore' ) as Colore,
--	JSON_QUERY(@j, '$.animali') as animali,
--	Animali1Nome = JSON_VALUE(@j, '$.animali[0].nome')

--SELECT *
--FROM openjson(@j)

--create schema its

--create table its.JSON (
--	id int identity(1,1),
--	j varchar(max)
--)

--alter table its.json
--	alter column j nvarchar(max) not null

--insert into its.json values
--(@j)

-- JOIN

--create view its.animali as
SELECT 
	ID = JSON_VALUE(j, '$.id')
	,COLORE = JSON_VALUE(j, '$.colore')
	,ANIMALENOME = JSON_VALUE(A.value, '$.nome')
	,ANIMALESPECIE = JSON_VALUE(A.value, '$.specie')
FROM its.json
	cross apply OPENJSON(J, '$.animali') A


declare @j nvarchar(max)= '{
	"id" : 3,
	"colore" : "blu",
	"animali" :  [
		{
			"nome" : "spillo",
			"specie" : "criceto"
		},
		{
			"nome" : "azzurro",
			"specie" : "inseparabili"
		}
	]
}'

insert into its.JSON values (@j)

select * from its.animali


select * from its.json

update its.JSON 
set j = JSON_MODIFY(j , 'strict $.animali[1].specie' , 'pappagallo' )
where id = 3