create view its.SuggestedLanguages as
	with a as 
	(-- elenco delle persone con conoscenze
		SELECT Person.Name as [Name1], Skill.[Language]
		FROM its.skill AS Skill,its.person AS Person,its.competence AS Knows
		WHERE 1=1
			and MATCH( Person -(Knows)-> Skill )
	),
	b as
	(-- Conoscenze delle persone seguite
		SELECT Person.Name, FollowedPerson.Name as FollowedPerson, Skill.[Language]
		FROM its.skill AS Skill,its.person AS Person,its.competence AS Knows,its.Follows AS Follows,its.Person AS FollowedPerson
		WHERE 1=1
			and MATCH( Person -(Follows)-> FollowedPerson -(Knows)-> Skill )
	)

	select b.Name as Target, b.FollowedPerson, b.[Language] as SuggestedLanguage
	from a right outer join b ON a.[Name1] = b.Name
	where a.[Language] <> b.[Language] OR a.[Language] is null


select * from its.SuggestedLanguages