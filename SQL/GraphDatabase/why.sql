use master;
go
Create database ITSGraph;
go
use ITSGraph;
go

CREATE TABLE dbo.person (
	id int identity(1,1),
	Name varchar(15)
)

CREATE TABLE dbo.Connections (
	ConnectionID int identity(1,1),
	FromID int,
	ToID int,
	[Value] int default(1)
)

insert into dbo.person values ('Alfa'),('Bravo'),('Charlie'),('Delta'),('Echo'),('Fox'),('Golf'),('Hotel'),('India'),('Juliet')	

/*
Person
 - Alfa			D,E
 - Bravo		F,G
 - Charlie		A,D,H
 - Delta		J,G
 - Echo			D,B,H
 - Fox			H,E,D
 - Golf			F
 - Hotel		G,B
 - India		J,A
 - Juliet		C,G
*/
insert into dbo.Connections(FromID, ToID) values 
(1,4)
,(1,5)
,(2,6)
,(2,7)
,(3,1)
,(3,4)
,(3,8)
/*	 - Delta		J,G
	 - Echo			D,B,H	*/
,(4,7)
,(4,10)
,(5,2)
,(5,4)
,(5,8)

select * 
from dbo.Connections

select
	P.Name, P.id, C.FromID, C.ToID, FP.id, FP.Name
from dbo.person P
	inner join dbo.Connections C
		ON P.id = C.FromID
	inner join dbo.person FP
		ON FP.id = C.ToID
/*
	A

B		C


D		E

	F
*/