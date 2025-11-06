-- Ejercicio a) Identificar tres procesos que consumen más CPU durante una operación masiva
SELECT TOP 3 
    session_id, 
    cpu_time, 
    total_elapsed_time,
    status, 
    blocking_session_id, 
    wait_type, 
    wait_time
FROM sys.dm_exec_requests
ORDER BY cpu_time DESC;
GO

-- Ejercicio b) Consultar desde T-SQL los bloqueos actuales en la base de datos
SELECT * 
FROM sys.dm_exec_requests 
WHERE blocking_session_id <> 0;
GO
