--Proyecto 1
-- Crear sesión Extended Events para capturar consultas lentas (+1 segundo)
CREATE EVENT SESSION CapturaConsultasLentas
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    ACTION (sqlserver.sql_text, sqlserver.database_name, sqlserver.client_app_name)
    WHERE (duration > 1000000  -- duración en microsegundos (1 segundo)
           AND sqlserver.database_name = 'QhatuPERU3')
)
ADD TARGET package0.event_file
(
    SET filename = 'C:\XE_Files\ConsultasLentas_QhatuPeru.xel',
        max_file_size = 50,
        max_rollover_files = 5
)
WITH
(
    STARTUP_STATE = OFF
);

-- Iniciar sesión
ALTER EVENT SESSION CapturaConsultasLentas ON SERVER STATE = START;

--Proyecto 2 
Use QhatuPERU;
go
-- Crear índice no clusterizado para búsqueda por DNI
CREATE NONCLUSTERED INDEX IX_Clientes_DNI
ON dbo.Clientes (DNI);

-- Crear índice no clusterizado para búsqueda por Apellidos
CREATE NONCLUSTERED INDEX IX_Clientes_Apellidos
ON dbo.Clientes (Apellidos);

-- Opcional: índice compuesto si existen búsquedas combinadas
-- (por ejemplo, WHERE DNI = '...' AND Apellidos = '...')
CREATE NONCLUSTERED INDEX IX_Clientes_DNI_Apellidos
ON dbo.Clientes (DNI, Apellidos);

--Busqueda por apeliidos
SELECT * FROM Clientes WHERE Apellidos = 'Quispe Segama';
--Indice compuesto
SELECT * FROM Clientes 
WHERE DNI = '74581236' AND Apellidos = 'Quispe Segama';

--Proyecto 3
--1. Ver fragmentación actual de índices (DMV)
SELECT 
    DB_NAME() AS BaseDatos,
    OBJECT_NAME(ips.object_id) AS Tabla,
    i.name AS NombreIndice,
    ips.index_id,
    ips.avg_fragmentation_in_percent AS Fragmentacion
FROM sys.dm_db_index_physical_stats(DB_ID('QhatuPeru'), NULL, NULL, NULL, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE i.index_id > 0  -- excluir heap
ORDER BY ips.avg_fragmentation_in_percent DESC;
--2. Aplicar mantenimiento automático de índices según nivel de fragmentación
DECLARE @object_id INT, @index_id INT, @frag FLOAT, @sql NVARCHAR(MAX);

DECLARE cur CURSOR FOR
SELECT 
    ips.object_id, 
    ips.index_id,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID('QhatuPeru'), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.indexes i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE i.index_id > 0;   -- evita heap

OPEN cur;
FETCH NEXT FROM cur INTO @object_id, @index_id, @frag;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @frag > 30
    BEGIN
        -- Reconstruir índice (mejor opción para alta fragmentación)
        SET @sql = 
            'ALTER INDEX [' + 
            (SELECT name FROM sys.indexes WHERE object_id = @object_id AND index_id = @index_id) + 
            '] ON [' + 
            (SELECT name FROM sys.objects WHERE object_id = @object_id) + 
            '] REBUILD;';
    END
    ELSE IF @frag BETWEEN 10 AND 30
    BEGIN
        -- Reorganizar índice (menos costoso)
        SET @sql = 
            'ALTER INDEX [' + 
            (SELECT name FROM sys.indexes WHERE object_id = @object_id AND index_id = @index_id) + 
            '] ON [' + 
            (SELECT name FROM sys.objects WHERE object_id = @object_id) + 
            '] REORGANIZE;';
    END
    ELSE
    BEGIN
        SET @sql = NULL;
    END

    IF @sql IS NOT NULL
    BEGIN
        PRINT 'Ejecutando: ' + @sql;
        EXEC sp_executesql @sql;
    END

    FETCH NEXT FROM cur INTO @object_id, @index_id, @frag;
END

CLOSE cur;
DEALLOCATE cur;

--Proyecto 4
DECLARE @ProductoID INT = 1;
DECLARE @Cantidad INT = 5;
DECLARE @PrecioUnitario DECIMAL(10,2);
DECLARE @StockActual INT;

-- Obtener el precio y stock
SELECT 
    @PrecioUnitario = Precio,
    @StockActual = Stock
FROM dbo.Productos
WHERE ProductoID = @ProductoID;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Validar stock suficiente
    IF @StockActual < @Cantidad
    BEGIN
        RAISERROR('Stock insuficiente para completar la venta.', 16, 1);
    END

    -- Insertar venta
    INSERT INTO dbo.Ventas (ProductoID, Cantidad, PrecioUnitario, Total)
    VALUES (@ProductoID, @Cantidad, @PrecioUnitario, @PrecioUnitario * @Cantidad);

    -- Actualizar stock
    UPDATE dbo.Productos
    SET Stock = Stock - @Cantidad
    WHERE ProductoID = @ProductoID;

    COMMIT TRANSACTION;
    PRINT 'La venta fue registrada correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error detectado. La transacción fue revertida.';
    PRINT ERROR_MESSAGE();
END CATCH;

--Proyecto 5
--5.1 Ver bloqueos activos usando DMVs
SELECT
    DB_NAME(r.database_id) AS BaseDatos,
    r.session_id AS SPID,
    r.blocking_session_id AS SPID_Bloqueador,
    s.host_name AS Host,
    s.login_name AS Usuario,
    r.status AS Estado,
    r.wait_type AS TipoEspera,
    r.wait_time AS TiempoEspera_ms,
    r.cpu_time AS CPU_ms,
    r.logical_reads AS LecturasLogicas,
    t.text AS ConsultaEjecutada
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE 
    r.blocking_session_id <> 0 
    OR r.session_id IN (SELECT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id <> 0)
ORDER BY r.wait_time DESC;
--5.2. Ver solo pares bloqueado ↔ bloqueador
SELECT
    r.blocking_session_id AS SPID_Bloqueador,
    r.session_id AS SPID_Bloqueado,
    t1.text AS Consulta_Bloqueadora,
    t2.text AS Consulta_Bloqueada,
    r.wait_type,
    r.wait_time,
    r.database_id
FROM sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(
    (SELECT sql_handle FROM sys.dm_exec_requests WHERE session_id = r.blocking_session_id)
) t1
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t2
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;
--5.3. Ver bloqueo específico por base de datos QhatuPeru
SELECT
    s.session_id,
    s.login_name,
    r.blocking_session_id,
    t.text AS Consulta,
    r.status,
    r.wait_type,
    r.wait_time
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.database_id = DB_ID('QhatuPeru')
  AND (r.blocking_session_id <> 0 OR r.session_id IN (
        SELECT blocking_session_id 
        FROM sys.dm_exec_requests 
        WHERE blocking_session_id <> 0
      ))
ORDER BY r.wait_time DESC;

--Proyecto 6
--6.1 Crear Tabla si no existe 

USE QhatuPeru;
GO

-- Tabla Productos
IF OBJECT_ID('Productos', 'U') IS NULL
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY,
    NombreProducto VARCHAR(100),
    Categoria VARCHAR(50)
);

-- Tabla Ventas
IF OBJECT_ID('Ventas', 'U') IS NULL
CREATE TABLE Ventas (
    VentaID INT PRIMARY KEY IDENTITY,
    ProductoID INT,
    Cantidad INT,
    Precio DECIMAL(10,2),
    FechaVenta DATE,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
--6.2. Insertar datos de prueba
INSERT INTO Productos (NombreProducto, Categoria)
VALUES ('Pollo', 'Abarrotes'), 
       ('Carne', 'Abarrotes'),
       ('Leche Entera', 'Lácteos'),
       ('Huevos', 'Granja');

INSERT INTO Ventas (ProductoID, Cantidad, Precio, FechaVenta)
VALUES 
(1, 5, 12.50, '2025-01-10'),
(1, 10, 11.00, '2025-01-12'),
(2, 7, 14.00, '2025-01-11'),
(3, 20, 4.50, '2025-01-12'),
(4, 30, 0.80, '2025-01-13');
--6.3. Consulta lenta a analizar
SELECT
    p.NombreProducto,
    SUM(v.Cantidad) AS TotalVendido,
    SUM(v.Cantidad * v.Precio) AS TotalGenerado
FROM Ventas v
INNER JOIN Productos p
    ON v.ProductoID = p.ProductoID
GROUP BY p.NombreProducto;
--6.4. Habilitar visualización del plan de ejecución
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Índices recomendados (resultado del análisis)
CREATE INDEX IX_Ventas_ProductoID ON Ventas(ProductoID);
CREATE INDEX IX_Productos_Nombre ON Productos(NombreProducto);

--Proyecto 7
--1. Crear tabla Clientes (si no existe)
USE QhatuPERU3	;
GO

IF OBJECT_ID('Clientes', 'U') IS NULL
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY,
    Nombres VARCHAR(100),
    Apellidos VARCHAR(100),
    DNI CHAR(8)
);
--2. Agregar columna ClienteID a Ventas (si aún no existe)
IF COL_LENGTH('Ventas','ClienteID') IS NULL
ALTER TABLE Ventas
ADD ClienteID INT FOREIGN KEY REFERENCES Clientes(ClienteID);
--3. Insertar datos de prueba
INSERT INTO Clientes (Nombres, Apellidos, DNI)
VALUES 
('Carlos', 'Sanchez Lopez', '72345678'),
('María', 'Huaman Torres', '81234567'),
('Pedro', 'Mendez Rojas', '70223344');

UPDATE Ventas
SET ClienteID = 1
WHERE VentaID IN (1,2);

UPDATE Ventas
SET ClienteID = 2
WHERE VentaID IN (3,4,5);

--4. Consulta original (lenta)
SELECT 
    ClienteID,
    SUM(Cantidad) AS TotalProductos,
    SUM(Cantidad * PrecioUnitario) AS TotalGenerado
FROM Ventas
WHERE FechaVenta BETWEEN '2025-01-01' AND '2025-01-31'
  AND ClienteID = 2
GROUP BY ClienteID;

--5. Crear índice compuesto recomendado
CREATE INDEX IX_Ventas_Cliente_Fecha
ON Ventas (ClienteID, FechaVenta)
INCLUDE (Cantidad, PrecioUnitario);
--6. Verificar mejora del plan de ejecución
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT 
    ClienteID,
    SUM(Cantidad) AS TotalProductos,
    SUM(Cantidad * PrecioUnitario) AS TotalGenerado
FROM Ventas
WHERE FechaVenta BETWEEN '2025-01-01' AND '2025-01-31'
  AND ClienteID = 2
GROUP BY ClienteID;

--Proyecto 8
--1. Verificar que la tabla Productos tenga la columna Precio
USE QhatuPERU3;
GO

IF COL_LENGTH('Productos', 'Precio') IS NULL
ALTER TABLE Productos
ADD Precio DECIMAL(10,2);
GO
--2. Insertar precios de ejemplo (si no existen)
UPDATE Productos SET Precio = 12.50 WHERE Nombre = 'Pollo';
UPDATE Productos SET Precio = 14.00 WHERE Nombre = 'Carne';
UPDATE Productos SET Precio = 4.50  WHERE Nombre = 'Leche Entera';
UPDATE Productos SET Precio = 0.80  WHERE Nombre = 'Huevos';
--3. Crear estadística manual sobre la columna Precio
CREATE STATISTICS Estadistica_Precio_Productos
ON Productos(Precio)
WITH FULLSCAN;   -- Fuerza a SQL Server a analizar todas las filas para mayor precisión

--4. Ejemplo de consulta que se beneficia
SELECT *
FROM Productos
WHERE Precio BETWEEN 5 AND 15;

--5. Comprobar que la estadística existe
SELECT name, auto_created, user_created, has_filter
FROM sys.stats
WHERE object_id = OBJECT_ID('Productos');

--Proyecto 9
-- 1. Habilitar Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;

--2. Crear Resource Pool limitado al 20% de CPU
CREATE RESOURCE POOL Pool_Analitico
WITH (
    MAX_CPU_PERCENT = 20,
    MIN_CPU_PERCENT = 0
);

--3. Crear grupo de trabajo asociado
CREATE WORKLOAD GROUP Grupo_Analitico
USING Pool_Analitico;

--4. Crear función clasificadora para enviar consultas analíticas al pool
CREATE FUNCTION dbo.Func_Clasificar_Sesiones()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @Grupo sysname;

    IF (APP_NAME() = 'AnalisisApp')
        SET @Grupo = 'Grupo_Analitico';
    ELSE
        SET @Grupo = 'default';

    RETURN @Grupo;
END;

--5. Asociar la función al Resource Governor
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.Func_Clasificar_Sesiones);

--6. Reconfigurar para aplicar cambios
ALTER RESOURCE GOVERNOR RECONFIGURE;

--7. Probar conexión identificada como analítica
USE QhatuPeru;
GO
SELECT APP_NAME();

--Proyecto 10
--1. Crear una sesión de Extended Events para auditoría
CREATE EVENT SESSION AuditoriaInsercionesProductos
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.client_app_name,
        sqlserver.username,
        sqlserver.database_name
    )
    WHERE (
        sqlserver.database_name = 'QhatuPeru3'
        AND sqlserver.sql_text LIKE '%INSERT INTO Productos%'
    )
)
ADD TARGET package0.event_file
(
    SET filename = 'C:\XE\AuditoriaProductos.xel',
        max_file_size = 10,
        max_rollover_files = 5
);
GO
ALTER EVENT SESSION AuditoriaInsercionesProductos ON SERVER STATE = START;
GO

-- 2. Insertar para probar auditoría

INSERT INTO Productos (Nombre, Descripcion, Categoria, Stock, Precio)
VALUES ('Queso Andino', 'Lácteos', 'Quesos', 10, 12.50);


--3. Leer resultados del archivo .xel
SELECT *
FROM sys.fn_xe_file_target_read_file(
    'C:\XE\AuditoriaProductos*.xel',
    NULL,
    NULL,
    NULL
);
