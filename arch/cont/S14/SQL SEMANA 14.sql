-- 1. Crear el job
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Job_Limpieza_Logs';

-- 2. Crear el paso
EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Job_Limpieza_Logs',
    @step_name = 'EliminarLogs',
    @subsystem = 'TSQL',
    @command = '
        DELETE FROM msdb.dbo.backupset
        WHERE backup_start_date < DATEADD(DAY, -30, GETDATE());
    ';

--3. Crear el horario diario a la 1am correctamente
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = 'Horario_Diario_1AM',
    @freq_type = 4,              -- Diario
    @freq_interval = 1,          -- Cada 1 día (obligatorio)
    @active_start_time = 010000; -- 01:00 AM

--4. Adjuntar el horario al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = 'Job_Limpieza_Logs',
    @schedule_name = 'Horario_Diario_1AM';

--5. Habilitar el job para el servidor
EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'Job_Limpieza_Logs';

--¿Respaldar la base cada día
BACKUP DATABASE QhatuPERU
TO DISK = 'C:\Backups\QhatuPERU_full.bak'
WITH INIT, FORMAT;
--Verificar integridad de base
DBCC CHECKDB ('QhatuPERU');
--Reconstruir índices
USE QhatuPERU;
GO
ALTER INDEX ALL ON Ventas REBUILD;
-- Ejemplo con T-SQL – Respaldar base
BACKUP DATABASE QhatuPERU
TO DISK = 'C:\Respaldos\QhatuPERU_full.bak'
WITH INIT;

--Ejemplo con T-SQL – Borrar
USE QhatuPERU;
GO
DELETE FROM LogsSistema
WHERE Fecha < DATEADD(MONTH, -6, GETDATE());
--Ejemplo de PowerShell desde SQL
EXEC xp_cmdshell 'powershell -command "Copy-Item C:\Backups\*.bak D:\RespaldoExterno\"';
--enviar correo a operador cuando falla un job
EXEC msdb.dbo.sp_notify_operator
    @name = 'OperadorDBA',
    @subject = 'Fallo en el Job',
    @body = 'El job de respaldo falló. Revisar inmediatamente.';
	--crear alerta por error crítico (824)
EXEC msdb.dbo.sp_add_alert
    @name = 'Alerta_Error_824',
    @message_id = 824,
    @severity = 0,                -- SE DEBE dejar en 0 cuando usas message_id
    @enabled = 1,
    @delay_between_responses = 60, -- evita spam de alertas
    @notification_message = 'Se ha detectado un error 824. Revisar inmediatamente.',
    @job_id = NULL;

EXEC msdb.dbo.sp_add_notification
    @alert_name = 'Alerta_Error_824',
    @operator_name = 'OperadorDBA',
    @notification_method = 1;   -- 1 = email


	--
	DELETE FROM msdb.dbo.backupset
WHERE backup_start_date < DATEADD(DAY, -30, GETDATE());



--Crea el job
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Limpieza_Logs_Antiguos';
--Agrega el paso
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Limpieza_Logs_Antiguos',
    @step_name = 'Eliminar',
    @subsystem = 'TSQL',
    @command = '
        DELETE FROM msdb.dbo.backupset
        WHERE backup_start_date < DATEADD(DAY, -30, GETDATE());
    ';
--Crea el horario diario a las 12:00 AM
EXEC msdb.dbo.sp_add_schedule 
    @schedule_name = 'Diario_12AM',
    @freq_type = 4,           -- Diario
    @freq_interval = 1,       -- Cada 1 día
    @active_start_time = 000000;   -- 12:00 AM

--Asocia el horario al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = 'Limpieza_Logs_Antiguos',
    @schedule_name = 'Diario_12AM';
--Asigna el job al servidor
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Limpieza_Logs_Antiguos';

	--Primero crear el procedimiento almacenado (reporte)
	Use QhatuPERU
	GO
CREATE PROCEDURE ReporteVentasSemanal
AS
BEGIN
    SELECT 
        fecha_venta,
        producto,
        cantidad,
        total
    FROM Ventas
    WHERE fecha_venta >= DATEADD(WEEK, -1, GETDATE());
END;
--Crear el job que ejecute ese procedimiento
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Job_Reporte_Semanal';

EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Job_Reporte_Semanal',
    @step_name = 'GenerarReporte',
    @subsystem = 'TSQL',
    @command = 'EXEC ReporteVentasSemanal;';

EXEC msdb.dbo.sp_add_schedule 
    @schedule_name = 'Semanal_Domingo_8AM',
    @freq_type = 8,            -- semanal
    @freq_interval = 1,        -- domingo
    @active_start_time = 080000;

EXEC msdb.dbo.sp_attach_schedule
    @job_name = 'Job_Reporte_Semanal',
    @schedule_name = 'Semanal_Domingo_8AM';

EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Job_Reporte_Semanal';

