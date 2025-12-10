--Mantenimiento recomendado:
Use QhatuPERU3;
UPDATE STATISTICS ARTICULO;
--O activar auto-update:
ALTER DATABASE QhatuPERU3 SET AUTO_UPDATE_STATISTICS ON;
--Menor a 30% → reorganizar:
ALTER INDEX PK__PROVEEDO__BFBE6B07AEFC9CA5 ON PROVEEDOR REORGANIZE;
ALTER INDEX PK_GUIA_DETALLE ON GUIA_DETALLE REORGANIZE;
--Mayor a 30% → reconstruir:
ALTER INDEX PK__PROVEEDO__BFBE6B07AEFC9CA5 ON PROVEEDOR REBUILD;
ALTER INDEX PK_GUIA_DETALLE ON GUIA_DETALLE REBUILD;
--¿Cómo obtenerlo?
SET SHOWPLAN_ALL ON;
--Mal ejemplo:
WHERE YEAR(Fecha) = 2024
--Mejor:
WHERE Fecha >= '2024-01-01' AND Fecha < '2025-01-01'

INNER JOIN, LEFT JOIN
--Ejemplo simple:
CREATE RESOURCE POOL PoolReportes 
WITH (MAX_CPU_PERCENT = 30);

ALTER RESOURCE GOVERNOR RECONFIGURE;
--PRACTICA 1
CREATE EVENT SESSION SlowQueries
ON SERVER
ADD EVENT sqlserver.rpc_completed(
    WHERE duration > 1000
),
ADD EVENT sqlserver.sql_batch_completed(
    WHERE duration > 1000
)
ADD TARGET package0.event_file(SET filename = 'C:\Temp\SlowQueries.xel');
GO

ALTER EVENT SESSION SlowQueries ON SERVER STATE = START;
--Luego se analiza con:
SELECT * FROM sys.fn_xe_file_target_read_file('C:\Temp\SlowQueries*.xel', NULL, NULL, NULL);

--Consulta original (ineficiente):
SELECT * 
FROM ORDEN_COMPRA
WHERE YEAR(FechaOrden) = 2023;
--
SELECT NumOrden, FechaOrden, FechaIngreso
FROM ORDEN_COMPRA
WHERE FechaOrden >= '2023-01-01'
  AND FechaIngreso <  '2024-01-01';
  --Supongamos la tabla:
CREATE TABLE Ventas(
    IdVenta INT PRIMARY KEY,
    FechaVenta DATETIME,
    IdCliente INT,
    Total DECIMAL(10,2)
);
--Para reportes y filtros por rango:
CREATE INDEX IX_Ventas_FechaVenta
ON Ventas(FechaVenta);
--Para análisis por cliente:
CREATE INDEX IX_Ventas_IdCliente
ON Ventas(IdCliente);

--
SELECT 
    DB_NAME() AS BD,
    OBJECT_NAME(object_id) AS Tabla,
    index_id,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Ventas'), NULL, NULL, 'DETAILED');

--Si la fragmentación es menor de 30% → REORGANIZE
ALTER INDEX IX_Ventas_FechaVenta ON Ventas REORGANIZE;
--Si es mayor de 30% → REBUILD
ALTER INDEX IX_Ventas_FechaVenta ON Ventas REBUILD;
--Actualizar estadísticas (muy importante)
UPDATE STATISTICS Ventas;

--
EXEC msdb.dbo.sp_add_alert
    @name = 'Alerta_Bloqueos',
    @message_id = 0,
    @severity = 0,
    @notification_message = 'Se detectó un bloqueo prolongado',
    @job_name = NULL,
    @performance_condition = 'Latches > 0',
    @delay_between_responses = 60,
    @include_event_description_in = 1;

	--
	EXEC msdb.dbo.sp_add_alert
    @name = 'Alerta_Deadlocks',
    @message_id = 1205,  -- Código de deadlock
    @severity = 0,
    @notification_message = 'Se produjo un deadlock en SQL Server.',
    @include_event_description_in = 1;


	--Enviar alerta si la CPU supera el 80% por más de un minuto:
EXEC msdb.dbo.sp_add_alert
    @name = 'CPU Alta',
    @message_id = 0,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 60,
    @include_event_description_in = 1,
    @performance_condition = 'SQLServer:Processor(_Total)\% Processor Time > 80',
    @job_id = NULL;
	--
	EXEC msdb.dbo.sp_add_operator  
    @name = 'AdminDB',  
    @email_address = 'admin@empresa.com';

	EXEC msdb.dbo.sp_add_notification  
    @alert_name = 'CPU Alta',  
    @operator_name = 'AdminDB',  
    @notification_method = 1;  -- Email


