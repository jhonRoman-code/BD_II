-- Simulación de eliminación de registros de Clientes
DELETE FROM Clientes WHERE ClienteID > 100;
GO

USE master;
GO

-- Restaurar la base de datos desde el respaldo más reciente
RESTORE DATABASE QhatuPeruNuevo
FROM DISK = 'C:\QhatuPeru\Backups\QhatuPeruNuevo_Daily.bak'
WITH REPLACE;
GO

-- Verificar la existencia de los registros restaurados
SELECT * FROM Clientes WHERE ClienteID > 100;
GO
