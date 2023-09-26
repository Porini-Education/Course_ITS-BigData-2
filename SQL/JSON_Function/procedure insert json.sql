alter procedure its.sp_insertJson 
@colore varchar(1000)
as

IF (@colore is null)
BEGIN
	raiserror('Il parametro @colore non può essere NULL', -1, -1, 'sp_insertJson')
END
ELSE
BEGIN

	declare @id int = (select max(id) + 1 from its.JSON )
	declare @j nvarchar(max)

	set @j = JSON_MODIFY('{}', '$.id', @id)
	set @j = JSON_MODIFY(@j , '$.colore', @colore)

	--select @j
	insert into its.JSON values (@j)
	PRINT 'La registrazione del JSON è andata a buon fine
	
Per verifica:
	SELECT TOP 100 * 
	FROM its.JSON
	ORDER BY id desc
	'
END

EXEC its.sp_insertJson @colore = 'viola'
;
GO



create or alter procedure its.sp_updateJson 
@colore varchar(20)
,@animaleNome   varchar(20)
,@animaleSpecie varchar(20)
as

IF (@colore is null)
BEGIN
	raiserror('Il parametro @colore non può essere NULL', -1, -1, 'sp_updateJson')
END
ELSE
BEGIN
	DECLARE @jAnimali nvarchar(max)

	set @jAnimali = 
		JSON_MODIFY(
			JSON_MODIFY('{}', '$.nome', @animaleNome),
			'$.specie',
			@animaleSpecie
			)
	--select @jAnimali, JSON_QUERY(@jAnimali)

	UPDATE its.JSON
	SET j = JSON_MODIFY( j , 'append $.animali' , JSON_QUERY(@jAnimali) )
	WHERE colore = @colore
END

exec its.sp_updateJson 'amaranto',  'spillo', 'ippopotamo'

select * from its.[JSON]
--where colore = 'carlo'

exec its.sp_insertJson 'Viola '
exec its.sp_updateJson ' viola', 'simba', 'leone'
exec its.sp_updateJson ' viola', 'rafiki', 'L''aquila'