-- aggiungiamo primary key su its.JSON

-- genera colonna calcolata NOT NULL grazie a ISNULL()
alter table its.json
 add Colore as ( isnull(json_value(j, '$.colore'),'') ) 

-- genera Primary Key su colonna calcolata Colore
alter table its.json
	add constraint pk_colore primary key (Colore)
