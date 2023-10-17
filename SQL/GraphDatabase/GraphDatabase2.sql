-- costruiamo una query base sulla nostra tabella node
-- quali sono gli utenti presenti?

select distinct Name
from its.person

-- senza usare la funzione MATCH vorrei mostrare i collegamenti di primo livello
-- nodo, edge
-- ANSI-92

select P.Name, FP.Name
from its.person P
	inner join its.follows F
		ON P.$node_id = F.$from_id
	inner join its.person FP
		ON F.$to_id = FP.$node_id

-- Traduciamo la query sopra con la funzione MATCH
-- vietato uso di ANSI-92

SELECT 
	PrimoLivello = Person.Name + ' -> ' + FollowedPerson.Name 
FROM its.Person as Person
	,its.Follows as Follows
	,its.Person as FollowedPerson
WHERE 1=1
	and MATCH( Person -(Follows)-> FollowedPerson )

-- Costruiamo la tabella delle Skill, e anche quale utente ha le specifiche skill

CREATE TABLE its.skill (
	id int identity,
	[Language] varchar(15)
) as NODE

INSERT INTO its.skill values 
('Python'),('T-SQL'),('R'),('C++'),('DAX'),('PowerShell')
select * from its.skill
select * from its.competence

CREATE TABLE its.Competence (Level tinyint DEFAULT(1)) AS EDGE

INSERT INTO its.Competence($from_id, $to_id) VALUES 
( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Alfa') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'Python') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Echo') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'Python') )
/****************************************************************************/
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'India') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'T-SQL') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Delta') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'T-SQL') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Fox') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'T-SQL') )
/****************************************************************************/
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Bravo') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'R') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Golf') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'C++') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Hotel') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'DAX') )
,( (SELECT $node_id FROM its.Person 
	WHERE Name = 'Juliet') , (SELECT $node_id FROM its.skill 
								WHERE [Language] = 'PowerShell') )


-- calcolare gli utenti e le loro competenze

SELECT Person.Name, Skill.[Language]
FROM its.skill AS Skill
	,its.person AS Person
	,its.competence AS Knows
WHERE MATCH( Person -(Knows)-> Skill )

-- Alfa segue Bravo e le competenze di Alfa

SELECT Person.Name, Skill.[Language], FollowedPerson.Name
FROM its.skill AS Skill
	,its.person AS Person
	,its.competence AS Knows
	,its.Follows AS Follows
	,its.Person AS FollowedPerson
WHERE MATCH( FollowedPerson <-(Follows)- Person -(Knows)-> Skill )

-- Date le Skill Python e SQL vorrei scoprire a chi suggerirle

-- Prima versione: Io conosco un mio collega, entrambi conosciamo Python o T-SQL
SELECT Person.Name, Skill.[Language], FollowedPerson.Name
FROM its.skill AS Skill
	,its.person AS Person
	,its.competence AS Knows
	,its.competence AS Knows2
	,its.Follows AS Follows
	,its.Person AS FollowedPerson
WHERE 1=1
	and Skill.[Language] in ('Python','T-SQL')
	and MATCH( Person -(Follows)-> FollowedPerson -(Knows)-> Skill )
	and MATCH( Person -(Knows2)-> Skill )

-- Seconda versione: non potendo usare il not MATCH, proviamo con le cte
with a as 
(-- elenco delle persone con conoscenze
	SELECT Person.Name as [Name1], Skill.[Language]
	FROM its.skill AS Skill,its.person AS Person,its.competence AS Knows
	WHERE 1=1
		--and Skill.[Language] in ('Python','T-SQL')
		and MATCH( Person -(Knows)-> Skill )
),
b as
(-- Conoscenze delle persone seguite
	SELECT Person.Name, FollowedPerson.Name as FollowedPerson, Skill.[Language]
	FROM its.skill AS Skill,its.person AS Person,its.competence AS Knows,its.Follows AS Follows,its.Person AS FollowedPerson
	WHERE 1=1
		and Skill.[Language] in ('Python','T-SQL')
		and MATCH( Person -(Follows)-> FollowedPerson -(Knows)-> Skill )
)

select b.Name as Target, b.FollowedPerson, b.[Language] as SuggestedLanguage
from a right outer join b ON a.[Name1] = b.Name
where a.[Language] <> b.[Language] OR a.[Language] is null

-- Python: charlie, fox, india
-- T-SQL: alfa, bravo, charlie, echo, golf
/*
Name	Language
Alfa	Python
Echo	Python
India	T-SQL
Delta	T-SQL
Fox		T-SQL
*/

-- Dato un linguaggio quali sono tutti i possibili utenti di partenza che possono accedervi
select *, count(*) OVER (PARTITION BY Name) as [#Languages] from
(
	select distinct 
		Name, Language
	from(
			select 
				Person.Name
				,STRING_AGG( FollowedPerson.Name, ' -> ' ) WITHIN GROUP (GRAPH PATH) as FollowedPeople
				,LAST_VALUE( FollowedPerson.Name ) WITHIN GROUP (GRAPH PATH) as LastPerson
				,count(FollowedPerson.Name) WITHIN GROUP (GRAPH PATH) as Level
				, skill.[Language]
			from 
				its.Person as Person
				,its.Follows for path as Follows	
				,its.Person for path as FollowedPerson
				,its.Competence as Knows
				,its.skill as Skill
			where 1=1
				and MATCH(SHORTEST_PATH(Person (-(Follows)-> FollowedPerson)+)  and LAST_NODE(FollowedPerson) -(Knows)-> Skill )
		) t
	WHERE T.Name <> T.LastPerson
) t2