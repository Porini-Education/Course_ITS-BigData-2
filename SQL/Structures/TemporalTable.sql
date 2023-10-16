-- Temporal Table

/*
utili per
	Auditing
	Rebuilding the data in case of inadvertent changes
	Projecting and reporting for historical trend analysis
	Protecting the data in case of accidental data loss
*/

use Test_C001 
GO


/*
	la tabella temporale deve avere i seguenti requisiti:
	- deve avere una primary key 
    - deve 2 campi di tipo datetime2 dichiarate GENERATED ALWAYS AS ROW START / END
	- un attributo PERIOD SYSTEM_TIME definito sui due campi datetime2

*/

--- Setup example
IF OBJECT_ID(N'dbo.Articles', N'U') IS NOT NULL
BEGIN
	IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Articles', N'U'), N'TableTemporalType') = 2
    ALTER TABLE dbo.Articles SET ( SYSTEM_VERSIONING = OFF );
	DROP TABLE IF EXISTS dbo.Articles, dbo.ArticlesHistory;
END;

-- Creazione nuova tabella Temporale
create table dbo.Articles
(
	IdArticle int not null CONSTRAINT PK_IdArticle PRIMARY KEY NONCLUSTERED,
	Category varchar(50),
	Price numeric (8,2),

	DateStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,  -- l'attributo HIDDEN non le visualizza nela select
	DateEnd   DATETIME2(0) GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (DateStart, DateEnd),
)
WITH ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.ArticlesHistory ) ); -- indicare il nome è facoltativo
;
GO

select * from dbo.Articles
select * from dbo.ArticlesHistory

-- Inserimento dati
insert into dbo.Articles
values (1,'Alfa',100),(2,'Bravo',200),(3,'Charlie',300), (4,'Delta',400);
GO

select * from dbo.Articles;
select * from dbo.ArticlesHistory; -- al momento vuota

-- update record
update dbo.Articles set Price = Price + 50 where IdArticle in(2);
GO

select * from dbo.Articles;
select * from dbo.ArticlesHistory ;  -- date valorizzate in UTC

-- le query "storiche" vengono fatte sulla tabella principale con l'opzione for
select *, DateStart,DateEnd from dbo.Articles for system_time all
where IdArticle=2
order by DateStart desc

-- nuova modifica
update dbo.Articles set Price = Price + 50 where IdArticle in(2,3);
GO

select *, DateStart,DateEnd from dbo.Articles for system_time all
/* valori del FOR SYSTEM_TIME:

	AS OF <datetime>  -- in un momento preciso
	FROM <startdatetime> TO <enddatetime>
	BETWEEN <startdatetime> AND <enddatetime>
	CONTAINED IN (<startdatetime> , <enddatetime>)
	ALL --> tutti i valori storici ed attuali

	senza FOR SYSTEM_TIME presenta il dato attuale
*/

insert into dbo.Articles values (5,'Echo',100);

select * from dbo.ArticlesHistory  order by id, DateStart; -- dato nuovo inserito non presente nella tabella storica


select * from dbo.Articles;
select *, DateStart,DateEnd from dbo.Articles FOR SYSTEM_TIME ALL
where IdArticle = 2;

select * from dbo.Articles FOR SYSTEM_TIME AS OF '2022-04-30 15:10:15' where IdArticle = 2;
select * from dbo.Articles FOR SYSTEM_TIME AS OF '2022-04-30 15:10:55' where IdArticle = 2;

--- eliminazione tabella
ALTER TABLE dbo.Articles SET ( SYSTEM_VERSIONING = OFF);
DROP TABLE dbo.Articles;

-- la tabella storica rimane
select * from dbo.ArticlesHistory ;
drop table dbo.ArticlesHistory  ;

---- Partendo da dati storici esistenti



-- Si può definire Temporal Table anche dopo averla creata

-- tabella storica non system versioned
drop table if exists dbo.ArticlesHistory;
GO

create table dbo.ArticlesHistory
(
	IdArticle int not null,
	Category varchar(50),
	Price numeric (8,2),
	DateStart DATETIME2(0) NOT NULL,
	DateEnd   DATETIME2(0) NOT NULL
);
GO

-- Dati storici di esempi  (NON inserire dati "futuri")
declare @DateStart datetime = '20210101';

insert into dbo.ArticlesHistory
values
(1,'alfa',1000,dateadd (month,0,@DateStart),dateadd (month,1,@DateStart)),
(1,'alfa',2000,dateadd (month,1,@DateStart),dateadd (month,2,@DateStart)),
(1,'alfa',3000,dateadd (month,2,@DateStart),dateadd (month,3,@DateStart)),
(1,'alfa',4000,dateadd (month,3,@DateStart),dateadd (month,4,@DateStart)),
(1,'alfa',5000,dateadd (month,4,@DateStart),dateadd (month,5,@DateStart)),
(1,'alfa',6000,dateadd (month,5,@DateStart),dateadd (month,6,@DateStart)),
(1,'alfa',7000,dateadd (month,6,@DateStart),dateadd (month,7,@DateStart)),
(1,'alfa',8000,dateadd (month,7,@DateStart),dateadd (month,8,@DateStart))
;
GO

update dbo.ArticlesHistory
set DateStart = DATEADD (second,1,Datestart);
GO


-- Tabella attuale
drop table if exists dbo.Articles;
GO

create table dbo.Articles
(
	IdArticle int not null primary key,
	Category varchar(50),
	Price numeric (8,2),
	DateStart DateTime2(0) not  null,
	DateEnd DateTime2(0) not null
	);
GO

insert into dbo.Articles 
select top 1 IdArticle,Category,Price,DateEnd,'99991231 23:59:59' from dbo.ArticlesHistory order by DateStart desc;
GO

select * from dbo.Articles;
select * from  dbo.ArticlesHistory;

-- modifiche alla tabella per renderla Temporal
ALTER TABLE dbo.Articles ADD PERIOD FOR SYSTEM_TIME (DateStart, DateEnd);

ALTER TABLE dbo.Articles ALTER COLUMN DateStart ADD HIDDEN; -- solo estetiche
ALTER TABLE dbo.Articles ALTER COLUMN DateEnd ADD HIDDEN;

ALTER TABLE dbo.Articles
  SET ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.ArticlesHistory ) );
GO

-- nuovo aggiornamento
update dbo.Articles set Price = 8001 where IdArticle=1;
insert into dbo.Articles values (2,'bravo',100);
go

select * from dbo.Articles; -- valore attuale

select *, DateStart, DateEnd from dbo.Articles  FOR SYSTEM_TIME ALL; -- tutta la storia

-- Data Puntuale
select * from dbo.Articles FOR SYSTEM_TIME AS OF '2021-02-02 00:00:00';
select * from dbo.Articles FOR SYSTEM_TIME AS OF '2021-03-02 00:00:00';

--Intervallo date

-- FROM BETWEEN dati in overlap: esistevano prima e finiscono dopo
select * from dbo.Articles  FOR SYSTEM_TIME FROM '2021-02-01 00:00:00' TO '2021-04-01 00:00:00'; 
select * from dbo.Articles  FOR SYSTEM_TIME BETWEEN '2021-02-01 00:00:00' AND '2021-04-01 00:00:00';  
select * from dbo.Articles  FOR SYSTEM_TIME BETWEEN '2021-02-01 00:00:00' AND '2021-03-31 23:59:59'; 


-- CONTAINED i valori che esistevano all'interno del periodo
select *, DateStart, DateEnd from dbo.Articles  FOR SYSTEM_TIME CONTAINED IN ('20210201' , '20210401');
select *, DateStart, DateEnd from dbo.Articles  FOR SYSTEM_TIME CONTAINED IN ('20210201' , '2021-03-31 23:59:59');

select * from dbo.Articles  FOR SYSTEM_TIME ALL; -- tutta la storia

-- eliminazione record
delete from dbo.Articles where IdArticle=1;
GO

select * from  dbo.Articles;

select *,DateStart, DateEnd  from dbo.Articles  FOR SYSTEM_TIME ALL; -- la storia del record eliminato rimane

-- reinserisco un record con lo stesso valore di primary key
insert into dbo.Articles values (1,'zulu',1900);

select * from  dbo.Articles;

select *,DateStart, DateEnd  from dbo.Articles  FOR SYSTEM_TIME ALL
where IdArticle=1
order by IdArticle, DateStart desc;  -- marcato il periodo di assenza del record

select * from dbo.Articles for system_time as of '20220501 12:43:00';


-- Indicazione dei periodi nel fuso orario di inserimento

-- select * from sys.time_zone_info

SELECT *,
  DateStart AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DateStart,
  CASE
    WHEN DateEnd = '9999-12-31 23:59:59'
      THEN DateEnd AT TIME ZONE 'UTC'
    ELSE DateEnd AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time'
  END AS DateEnd
FROM 
	dbo.Articles FOR SYSTEM_TIME ALL;

select * from dbo.Articles for system_time as of '20220501 12:43:00';

declare @momento datetime2;
set @momento = (select  convert (datetime2,'20220501 14:43:00') AT TIME ZONE 'Central European Standard Time' AT TIME ZONE 'UTC')
select @momento;

select * from dbo.Articles for system_time as of @momento;
select * from dbo.Articles for system_time as of '20220501 12:43:00';




-- anno precedente ad oggi
	--DECLARE @T VARCHAR(60)= format (getdate()-360, 'yyyyMMdd HH:mm:ss');
	--select * from dbo.Articles FOR SYSTEM_TIME AS OF @T;


-- Cleanup finale

IF OBJECT_ID(N'dbo.Articles', N'U') IS NOT NULL
BEGIN
	IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Articles', N'U'), N'TableTemporalType') = 2
    ALTER TABLE dbo.Articles SET ( SYSTEM_VERSIONING = OFF );
	DROP TABLE IF EXISTS dbo.Articles, dbo.ArticlesHistory;
END;
