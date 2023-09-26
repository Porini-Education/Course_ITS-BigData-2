-- SQL INJECTION
-- per sicurezza facciamo un backup

backup database Test_C001 to disk = 'C:\Temp\test_c001.bak'


restore database ITSJSON from disk = 'C:\Temp\test_c001.bak'
	with
		MOVE 'Test_C001_01' TO 'C:\Temp\BAK\Test_C001_01.mdf',
		MOVE 'Test_C001_02' TO 'C:\Temp\BAK\Test_C001_02.ndf',
		MOVE 'C001_M01_log' TO 'C:\Temp\BAK\Test_C001_log.ldf'

use ITSJSON

/*
usando le stored procedure che abbiamo creato noi
1. droppare la vista its.animali
2. troncare la tabella its.json
3. droppare il database
*/

EXEC its.sp_insertJson @colore = 'exec(''drop view its.animali'')'

SELECT TOP 100 * 
FROM its.JSON
ORDER BY id desc