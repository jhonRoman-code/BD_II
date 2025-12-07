--Proyecto 1 
-- 1) Crear login SQL con política de contraseñas y expiración
CREATE LOGIN login_sql_alumno
WITH PASSWORD = 'P@ssW0rdAlumno2025!'   -- usar contraseña segura en producción
     , CHECK_POLICY = ON               -- enforce Windows password policy
     , CHECK_EXPIRATION = ON;

-- 2) (Simulado) Crear login Windows. En un entorno sin dominio esto puede fallar; es la forma estándar.
CREATE LOGIN [Aurora\alumno_win] FROM WINDOWS;

-- 3) Mapear ambos usuarios en la base QhatuPeru
USE QhatuPERU;
CREATE USER alumno_sql FOR LOGIN login_sql_alumno;
CREATE USER [Aurora\alumno_win] FOR LOGIN [Aurora\alumno_win];

-- 4) Forzar expiración inmediata del login SQL (cambiar contraseña y exigir cambio)
ALTER LOGIN login_sql_alumno WITH PASSWORD = 'TempP@ss123!' MUST_CHANGE;

-- 5) Verificar configuración de los logins (comprobación)
SELECT name, type_desc, is_expiration_checked, is_policy_checked
FROM sys.sql_logins
WHERE name = 'login_sql_alumno';

-- Si quieres probar un intento de login fallido, hazlo desde cliente (sqlcmd/SSMS) con credenciales erradas para generar eventos en el log.
--Proyecto 2 
-- 1) Habilitar opciones avanzadas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
-- 2) Deshabilitar xp_cmdshell por seguridad
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
-- 3) Deshabilitar autenticación de bases contenidas
EXEC sp_configure 'contained database authentication', 0;
RECONFIGURE;
-- 4) Eliminar credencial previa si existía
USE master;
IF EXISTS (SELECT * FROM sys.credentials WHERE name = 'Credencial_Agent_Service')
    DROP CREDENTIAL Credencial_Agent_Service;
GO
-- 5) Crear credencial con usuario local válido
-- IMPORTANTE: la contraseña debe ser la real del usuario Windows 'Aurora\alumno_win'
CREATE CREDENTIAL Credencial_Agent_Service
WITH IDENTITY = 'Aurora\alumno_win', SECRET = 'P@ssW0rdAlumno2025!';
GO
-- 6) Crear proxy vinculado a la credencial
USE msdb;
-- Si el proxy ya existe, se elimina para evitar errores
IF EXISTS (SELECT * FROM msdb.dbo.sysproxies WHERE name = 'Proxy_Agent_AccesoOS')
    EXEC msdb.dbo.sp_delete_proxy @proxy_name = N'Proxy_Agent_AccesoOS';
GO
EXEC dbo.sp_add_proxy
    @proxy_name = N'Proxy_Agent_AccesoOS',
    @credential_name = N'Credencial_Agent_Service',
    @enabled = 1;
GO
-- 7) Asignar subsistemas (CmdExec y PowerShell)
EXEC dbo.sp_grant_proxy_to_subsystem
   @proxy_name = N'Proxy_Agent_AccesoOS',
   @subsystem_id = 3;  -- CmdExec
GO
EXEC dbo.sp_grant_proxy_to_subsystem
   @proxy_name = N'Proxy_Agent_AccesoOS',
   @subsystem_id = 12; -- PowerShell
GO
-- 8) Conceder permiso al usuario Windows para usar el proxy
EXEC dbo.sp_grant_login_to_proxy
   @proxy_name = N'Proxy_Agent_AccesoOS',
   @login_name = N'Aurora\alumno_win';
GO
--Proyecto 3
USE QhatuPERU;
GO
-- 1) Crear rol personalizado
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ventas_readwrite')
    CREATE ROLE ventas_readwrite;
GO
-- 2) Conceder permisos específicos sobre los objetos
GRANT SELECT, INSERT, UPDATE ON dbo.GUIA_ENVIO TO ventas_readwrite;
GRANT SELECT, INSERT, UPDATE ON dbo.GUIA_DETALLE TO ventas_readwrite;
GO
-- 3) Crear los usuarios si no existen (uno SQL y otro Windows)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'alumno_sql')
    CREATE USER alumno_sql FOR LOGIN alumno_sql;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Aurora\alumno_win')
    CREATE USER [Aurora\alumno_win] FOR LOGIN [Aurora\alumno_win];
GO
-- 4) Asignar los usuarios al rol personalizado
EXEC sp_addrolemember 'ventas_readwrite', 'alumno_sql';
EXEC sp_addrolemember 'ventas_readwrite', 'Aurora\alumno_win';
GO
-- 5) Mostrar diferencia con rol fijo db_datareader (consulta demostrativa)
SELECT dp.name AS principal, r.name AS role_name
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE r.name IN ('ventas_readwrite', 'db_datareader');
GO
--Proyecto 4
USE QhatuPERU;
GO
-- 1) Crear rol de analista
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'analista_inventario')
    CREATE ROLE analista_inventario;
GO
-- 2) Conceder SELECT sobre la tabla INVENTARIO
GRANT SELECT ON dbo.INVENTARIO TO analista_inventario;
GO
-- 3a) Crear vista sin columnas de precios
IF OBJECT_ID('dbo.vw_INVENTARIO_SIN_PRECIOS', 'V') IS NOT NULL
    DROP VIEW dbo.vw_INVENTARIO_SIN_PRECIOS;
GO
CREATE VIEW dbo.vw_INVENTARIO_SIN_PRECIOS
AS
SELECT IdProducto, NombreProducto, Cantidad, Ubicacion
FROM dbo.INVENTARIO;
GO
-- 3b) Conceder SELECT sobre la vista al rol
GRANT SELECT ON dbo.vw_INVENTARIO_SIN_PRECIOS TO analista_inventario;
GO
-- 3c) Denegar SELECT directo sobre la tabla INVENTARIO (para restringir acceso total)
DENY SELECT ON dbo.INVENTARIO TO analista_inventario;
GO
-- 3d) Crear rol para jefe de compras (con acceso completo)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jefe_compras')
    CREATE ROLE jefe_compras;
GO
GRANT SELECT ON dbo.INVENTARIO TO jefe_compras;
GO
-- 4) Asignar usuario analista
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'alumno_sql')
    CREATE USER alumno_sql2 FOR LOGIN alumno_sql;
GO
EXEC sp_addrolemember 'analista_inventario', 'alumno_sql';
GO
--Proyecto 5
-- 1) Crear master key solo si no existe
USE master;
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'VeryStrongMasterKeyPass!2025';
    PRINT 'Master Key creada correctamente.';
END
ELSE
    PRINT 'Master Key ya existe, se omite creación.';
GO
-- 2) Crear certificado solo si no existe
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'TDE_Cert_QhatuPeru')
BEGIN
    CREATE CERTIFICATE TDE_Cert_QhatuPeru
    WITH SUBJECT = 'Certificado TDE para QhatuPeru';
    PRINT 'Certificado TDE creado correctamente.';
END
ELSE
    PRINT 'Certificado TDE ya existe.';
GO
-- 3) Crear Database Encryption Key solo si no existe
USE QhatuPeru;
IF NOT EXISTS (SELECT * FROM sys.dm_database_encryption_keys)
BEGIN
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TDE_Cert_QhatuPeru;
    PRINT 'Database Encryption Key creada correctamente.';
END
ELSE
    PRINT 'Database Encryption Key ya existe.';
GO
-- 4) Activar cifrado solo si está desactivado
IF NOT EXISTS (
    SELECT * FROM sys.dm_database_encryption_keys 
    WHERE database_id = DB_ID('QhatuPeru') AND encryption_state = 3
)
BEGIN
    ALTER DATABASE QhatuPeru SET ENCRYPTION ON;
    PRINT 'Cifrado TDE activado.';
END
ELSE
    PRINT 'TDE ya se encuentra activo.';
GO
-- 5) Comprobar estado
SELECT 
    db.name AS DatabaseName, 
    dek.encryption_state,
    CASE dek.encryption_state
        WHEN 0 THEN 'No cifrada'
        WHEN 1 THEN 'En proceso de descifrado'
        WHEN 2 THEN 'En proceso de cifrado'
        WHEN 3 THEN 'Cifrada'
        WHEN 4 THEN 'Clave de cifrado cambiando'
        WHEN 5 THEN 'Descifrado en proceso'
        ELSE 'Desconocido'
    END AS Estado,
    dek.percent_complete,
    dek.key_algorithm
FROM sys.dm_database_encryption_keys dek
JOIN sys.databases db ON dek.database_id = db.database_id
WHERE db.name = 'QhatuPeru';
GO
--Recomendacion
BACKUP CERTIFICATE TDE_Cert_QhatuPeru
TO FILE = 'C:\Backups\TDE_Cert_QhatuPeru.cer'
WITH PRIVATE KEY (
    FILE = 'C:\Backups\TDE_Cert_QhatuPERU_PrivateKey.pvk',
    ENCRYPTION BY PASSWORD = 'BackupKey#2025!'
);
--Proyecto 6
USE QhatuPeru;
GO
-------------------------------------------------------
-- 1) CREAR COLUMN MASTER KEY (CMK)
-------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.column_master_keys WHERE name = 'CMK_QhatuPeru')
BEGIN
    CREATE COLUMN MASTER KEY [CMK_QhatuPeru]
    WITH (
        KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
        KEY_PATH = N'CurrentUser\My\<THUMBPRINT_DEL_CERTIFICADO>'
    );
    PRINT 'CMK_QhatuPeru creada correctamente.';
END
ELSE
BEGIN
    PRINT 'CMK_QhatuPeru ya existe.';
END;
GO

-------------------------------------------------------
-- 2) CREAR COLUMN ENCRYPTION KEY (CEK)
-- Este paso debe realizarse con el Asistente de Always Encrypted
-- en SSMS (no mediante T-SQL puro) para generar un valor válido.
-------------------------------------------------------
-- Script de referencia: se ejecuta automáticamente por el Asistente.
-- CREATE COLUMN ENCRYPTION KEY [CEK_QhatuPeru]
-- WITH VALUES (
--     COLUMN_MASTER_KEY = [CMK_QhatuPeru],
--     ENCRYPTED_VALUE = 0x<VALOR_GENERADO_POR_CLIENTE>
-- );
GO

-------------------------------------------------------
-- 3) CREAR TABLA PROVEEDOR SI NO EXISTE
-------------------------------------------------------
IF OBJECT_ID('dbo.PROVEEDOR', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PROVEEDOR (
        IdProveedor INT IDENTITY(1,1) PRIMARY KEY,
        NombreProveedor NVARCHAR(100),
        PrecioProveedor DECIMAL(18,2)
    );
    PRINT 'Tabla PROVEEDOR creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La tabla PROVEEDOR ya existe.';
END;
GO

-------------------------------------------------------
-- 4) AGREGAR COLUMNA CIFRADA (una vez creada la CEK real)
-------------------------------------------------------
-- ALTER TABLE dbo.PROVEEDOR
-- ADD PrecioProveedor_ENC DECIMAL(18,2)
--     ENCRYPTED WITH (
--         COLUMN_ENCRYPTION_KEY = [CEK_QhatuPeru],
--         ENCRYPTION_TYPE = DETERMINISTIC,
--         ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
--     )
--     NULL;
GO
------------------------------------------------------------
-- PROYECTO 7: Auditoría de Logins y DDL en SQL Server
------------------------------------------------------------

-- 1) Crear Server Audit (archivo de auditoría)
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit_Logins_And_DDL')
BEGIN
    CREATE SERVER AUDIT Audit_Logins_And_DDL
    TO FILE (
        FILEPATH = 'C:\SQLAudit\Audits\',  -- asegúrate de que la carpeta exista
        MAXSIZE = 100 MB,
        MAX_ROLLOVER_FILES = 10
    )
    WITH (
        QUEUE_DELAY = 1000,
        ON_FAILURE = CONTINUE
    );
    PRINT 'Server Audit creado correctamente.';
END
ELSE
BEGIN
    PRINT 'Server Audit ya existe.';
END;
GO

-- 2) Habilitar el Server Audit
ALTER SERVER AUDIT Audit_Logins_And_DDL
WITH (STATE = ON);
GO

------------------------------------------------------------
-- 3) Crear Server Audit Specification para logins
------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.server_audit_specifications WHERE name = 'ServerAuditSpec_Logins')
BEGIN
    CREATE SERVER AUDIT SPECIFICATION ServerAuditSpec_Logins
    FOR SERVER AUDIT Audit_Logins_And_DDL
        ADD (FAILED_LOGIN_GROUP),
        ADD (SUCCESSFUL_LOGIN_GROUP)
    WITH (STATE = ON);
    PRINT 'Server Audit Specification para logins creada y activada.';
END
ELSE
BEGIN
    PRINT 'Server Audit Specification para logins ya existe.';
END;
GO

------------------------------------------------------------
-- 4) Crear Database Audit Specification para operaciones DDL
------------------------------------------------------------
USE QhatuPeru;
GO

IF NOT EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'DB_AuditSpec_DDL_Qhatu')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION DB_AuditSpec_DDL_Qhatu
    FOR SERVER AUDIT Audit_Logins_And_DDL
        ADD (DATABASE_OBJECT_CHANGE_GROUP)
    WITH (STATE = ON);
    PRINT 'Database Audit Specification creada y activada.';
END
ELSE
BEGIN
    PRINT 'Database Audit Specification ya existe.';
END;
GO

------------------------------------------------------------
-- 5) Verificación del estado de la auditoría
------------------------------------------------------------
SELECT name, is_state_enabled, queue_delay, on_failure_desc
FROM sys.server_audits;

SELECT name, is_state_enabled
FROM sys.server_audit_specifications;

SELECT name, is_state_enabled
FROM sys.database_audit_specifications;
GO
----------------------------------------------------------
----------------------------------------------------------
-- Proyecto 8
USE master;
GO

----------------------------------------------------------
-- 1. Eliminar la sesión si ya existe
----------------------------------------------------------
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'XE_Qhatu_Deadlocks_Logins')
    DROP EVENT SESSION XE_Qhatu_Deadlocks_Logins ON SERVER;
GO

----------------------------------------------------------
-- 2. Crear la sesión de Extended Events
----------------------------------------------------------
-- 📂 Asegúrate de crear previamente la carpeta:
--     C:\XEvents\QhatuPeru
-- y otorgar permisos de escritura al servicio de SQL Server.

CREATE EVENT SESSION XE_Qhatu_Deadlocks_Logins
ON SERVER
-- Captura de eventos de deadlock (compatible en todas las ediciones)
ADD EVENT sqlserver.lock_deadlock_chain,
-- Captura de intentos de inicio de sesión fallido (error 18456)
ADD EVENT sqlserver.error_reported
(
    ACTION (sqlserver.sql_text, sqlserver.client_app_name)
    WHERE ([error_number] = 18456)
)
-- Destino de archivo de eventos (.xel)
ADD TARGET package0.event_file
(
    SET filename = N'C:\XEvents\QhatuPeru\QhatuXe.xel',
        max_file_size = 20,            -- Tamaño máximo por archivo (MB)
        max_rollover_files = 6         -- Archivos rotativos
)
-- Configuración de la sesión
WITH (
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 1 SECONDS,
    STARTUP_STATE = OFF
);
GO

----------------------------------------------------------
-- 3. Iniciar la sesión
----------------------------------------------------------
ALTER EVENT SESSION XE_Qhatu_Deadlocks_Logins ON SERVER STATE = START;
GO

----------------------------------------------------------
-- 4. Crear vista para leer los archivos de Extended Events
----------------------------------------------------------
USE QhatuPeru;
GO

IF OBJECT_ID('dbo.vw_ExtendedEvents_Qhatu', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ExtendedEvents_Qhatu;
GO

CREATE VIEW dbo.vw_ExtendedEvents_Qhatu
AS
SELECT
    event_data.value('(event/@name)[1]', 'nvarchar(100)') AS event_name,
    event_data.value('(event/@timestamp)[1]', 'datetime2') AS [timestamp],
    event_data.value('(event/data/value)[1]', 'nvarchar(max)') AS data_payload,
    event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(256)') AS client_app
FROM
(
    SELECT CAST(event_data AS xml) AS event_data
    FROM sys.fn_xe_file_target_read_file('C:\XEvents\QhatuPeru\QhatuXe*.xel', NULL, NULL, NULL)
) AS x;
GO

----------------------------------------------------------
-- 5. Consultar los eventos capturados
----------------------------------------------------------
SELECT TOP 100 *
FROM dbo.vw_ExtendedEvents_Qhatu
ORDER BY [timestamp] DESC;
GO

----------------------------------------------------------
-- 6. Validar que la sesión de Extended Events esté activa
----------------------------------------------------------
SELECT 
    s.name AS SessionName,
    s.create_time AS StartTime,
    CASE 
        WHEN s.name IS NOT NULL THEN 'ACTIVA'
        ELSE 'DETENIDA'
    END AS Estado
FROM sys.dm_xe_sessions AS s
WHERE s.name = 'XE_Qhatu_Deadlocks_Logins';
GO
--Proyecto 9
USE QhatuPeru;
GO

/* 1) Crear la tabla PROVEEDOR si no existe */
IF OBJECT_ID('dbo.PROVEEDOR','U') IS NULL
BEGIN
    CREATE TABLE dbo.PROVEEDOR (
        IdProveedor INT IDENTITY PRIMARY KEY,
        NomProveedor NVARCHAR(200),      -- Nombre del proveedor
        Telefono VARCHAR(20),            -- Teléfono a enmascarar
        CodProveedor VARCHAR(20)         -- Código del proveedor
    );
END
GO

/* 2) Aplicar Dynamic Data Masking sobre Telefono si no está enmascarado */
DECLARE @isMasked INT;
SELECT @isMasked = COUNT(*)
FROM sys.masked_columns mc
JOIN sys.columns c ON mc.column_id = c.column_id AND mc.object_id = c.object_id
WHERE OBJECT_NAME(c.object_id) = 'PROVEEDOR' AND c.name = 'Telefono';

IF @isMasked = 0
BEGIN
    ALTER TABLE dbo.PROVEEDOR
    ALTER COLUMN Telefono VARCHAR(20) MASKED WITH (FUNCTION = 'partial(2,"****",2)') NULL;
END
GO

/* 3) Insertar fila de prueba */
INSERT INTO dbo.PROVEEDOR (NomProveedor, Telefono, CodProveedor)
VALUES 
('ProveedorPrueba1','987654321','20123456789'),
('ProveedorPrueba2','912345678','20123456788');
GO

/* 4) Crear vista segura simple (sin funciones ni roles) */
IF OBJECT_ID('dbo.vw_PROVEEDOR_Segura','V') IS NOT NULL
    DROP VIEW dbo.vw_PROVEEDOR_Segura;
GO

CREATE VIEW dbo.vw_PROVEEDOR_Segura
AS
SELECT
    CodProveedor,
    NomProveedor,
    Telefono AS TelefonoVisible
FROM dbo.PROVEEDOR;
GO

/* 5) Consultar la vista para ver la máscara aplicada */
SELECT * FROM dbo.vw_PROVEEDOR_Segura;
GO
--Proyecto 10
-- =========================
-- 1) Crear rol auditor_seguridad
-- =========================
USE QhatuPeru;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'auditor_seguridad')
    EXEC sp_addrole 'auditor_seguridad';
GO

-- Conceder permisos de lectura limitados a objetos de auditoría / vistas relevantes
-- (Se ajustará según existan objetos; ejemplo para tabla interna de auditoría)
IF OBJECT_ID('dbo.AuditoriaCambiosCriticos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditoriaCambiosCriticos (
        Id INT IDENTITY PRIMARY KEY,
        Usuario NVARCHAR(256),
        Tabla NVARCHAR(128),
        Operacion NVARCHAR(50),
        Fecha DATETIME2 DEFAULT SYSUTCDATETIME(),
        Detalle NVARCHAR(MAX)
    );
END
GO

GRANT SELECT ON dbo.AuditoriaCambiosCriticos TO auditor_seguridad;
GO

-- =========================
-- 2) Habilitar TDE si no está habilitado
-- =========================
USE master;
GO

-- Crear Master Key (si no existe)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MuyFuerteMasterKey2025!';
END
GO

-- Crear/usar certificado para TDE
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'TDE_Cert_QhatuPeru')
BEGIN
    CREATE CERTIFICATE TDE_Cert_QhatuPeru
    WITH SUBJECT = 'Certificado TDE para QhatuPeru';
END
GO

-- Crear Database Encryption Key en QhatuPeru y activar TDE
USE QhatuPeru;
GO

IF NOT EXISTS (SELECT * FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID('QhatuPeru'))
BEGIN
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TDE_Cert_QhatuPeru;
    ALTER DATABASE QhatuPeru SET ENCRYPTION ON;
END
ELSE
BEGIN
    -- Si ya existe, mostramos el estado
    SELECT db.name, dek.encryption_state, dek.key_algorithm
    FROM sys.dm_database_encryption_keys dek
    JOIN sys.databases db ON dek.database_id = db.database_id
    WHERE db.name = 'QhatuPeru';
END
GO

-- =========================
-- 3) Preparar Always Encrypted (CMK + CEK placeholders) y crear columna cifrada
-- =========================
USE QhatuPeru;
GO

-- 3.1 Crear Column Master Key (apunta a un certificado en el almacén de Windows o a Azure Key Vault)
IF NOT EXISTS (SELECT * FROM sys.column_master_keys WHERE name = 'CMK_QhatuPeru')
BEGIN
    CREATE COLUMN MASTER KEY CMK_QhatuPeru
    WITH (
        KEY_STORE_PROVIDER_NAME = 'MSSQL_CERTIFICATE_STORE',
        KEY_PATH = 'CurrentUser\My\THUMBPRINT_PLACEHOLDER'
    );
    -- Reemplaza THUMBPRINT_PLACEHOLDER por el thumbprint real del certificado en el almacén del servidor/cliente.
END
GO

-- 3.2 Crear Column Encryption Key (CEK).
-- ENCRYPTED_VALUE debe ser generado por el cliente (SSMS / PowerShell / .NET) usando la CMK.
-- Aquí se muestra el DDL con placeholder: reemplaza ENCRYPTED_VALUE con el valor real producido por el cliente.
IF NOT EXISTS (SELECT * FROM sys.column_encryption_keys WHERE name = 'CEK_QhatuPeru')
BEGIN
    -- --> REEMPLAZAR EL ENCRYPTED_VALUE CON EL VALOR GENERADO DESDE CLIENTE
    CREATE COLUMN ENCRYPTION KEY CEK_QhatuPeru
    WITH VALUES (
        (
            COLUMN_MASTER_KEY = CMK_QhatuPeru,
            ENCRYPTED_VALUE = 0xDEADBEEF -- <<< PLACEHOLDER: reemplazar con valor real
        )
    );
END
GO

-- 3.3 Crear tabla CLIENTE y añadir columna cifrada (si CEK ya existe)
IF OBJECT_ID('dbo.CLIENTE','U') IS NULL
BEGIN
    CREATE TABLE dbo.CLIENTE (
        IdCliente INT IDENTITY PRIMARY KEY,
        Nombre NVARCHAR(200),
        NumeroDocumento NVARCHAR(100) NULL
    );
END
GO

-- Añadir columna cifrada (si CEK existe). Si CEK aún no se puede crear, deja este bloque hasta que CEK esté listo.
IF EXISTS (SELECT * FROM sys.column_encryption_keys WHERE name = 'CEK_QhatuPeru')
BEGIN
    IF COL_LENGTH('dbo.CLIENTE','NumeroDocumento_ENC') IS NULL
    BEGIN
        ALTER TABLE dbo.CLIENTE
        ADD NumeroDocumento_ENC NVARCHAR(100) COLLATE Latin1_General_BIN
            ENCRYPTED WITH (
                COLUMN_ENCRYPTION_KEY = CEK_QhatuPeru,
                ENCRYPTION_TYPE = Deterministic,
                ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
            ) NULL;
    END
END
ELSE
BEGIN
    PRINT 'CEK_QhatuPeru no existe aún. Genera ENCRYPTED_VALUE usando el cliente y crea CEK antes de añadir la columna cifrada.';
END
GO

-- =========================
-- 4) Configurar auditoría de accesos a la tabla CLIENTE (SELECT/UPDATE/DELETE)
-- =========================
USE master;
GO

-- 4.1 Crear server audit (archivo)
IF NOT EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Audit_QhatuPeru_Access')
BEGIN
    CREATE SERVER AUDIT Audit_QhatuPeru_Access
    TO FILE ( FILEPATH = 'C:\SQLAudit\QhatuPeru\' , MAX_FILES = 20 )
    WITH (ON_FAILURE = CONTINUE);
    ALTER SERVER AUDIT Audit_QhatuPeru_Access WITH (STATE = ON);
END
GO

-- 4.2 Crear Database Audit Specification para QhatuPeru
USE QhatuPeru;
GO

IF NOT EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'DBAuditSpec_SensitiveTableAccess')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION DBAuditSpec_SensitiveTableAccess
    FOR SERVER AUDIT Audit_QhatuPeru_Access
        ADD (SELECT ON OBJECT::dbo.CLIENTE BY PUBLIC),
        ADD (UPDATE ON OBJECT::dbo.CLIENTE BY PUBLIC),
        ADD (DELETE ON OBJECT::dbo.CLIENTE BY PUBLIC)
    WITH (STATE = ON);
END
GO

-- =========================
-- 5) Procedimiento para registrar cambios críticos localmente (y complementar la auditoría)
-- =========================
USE QhatuPeru;
GO

IF OBJECT_ID('dbo.sp_RegistrarCambioCritico', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarCambioCritico;
GO

CREATE PROCEDURE dbo.sp_RegistrarCambioCritico
    @Tabla NVARCHAR(128),
    @Operacion NVARCHAR(50),
    @Detalle NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditoriaCambiosCriticos (Usuario, Tabla, Operacion, Detalle)
    VALUES (SUSER_SNAME(), @Tabla, @Operacion, @Detalle);

    -- Emitir evento informativo (se puede recoger en logs/agent) sin detener ejecución
    RAISERROR ('CambioCritico en %s: %s por %s', 10, 1, @Tabla, @Operacion, SUSER_SNAME()) WITH NOWAIT;
END;
GO

-- =========================
-- 6) Otorgar permisos y documentar roles
-- =========================
-- Otorgar SELECT a auditor_seguridad en la tabla de auditoría (ya concedido arriba),
-- y conceder EXEC sobre el procedimiento de registro a roles de administración si se requiere.
GRANT EXECUTE ON dbo.sp_RegistrarCambioCritico TO db_owner; -- ejemplo, ajustar según roles reales
GO

-- =========================
-- 7) Mensaje final / comprobación
-- =========================
PRINT 'Proyecto 10: pasos ejecutados. Revise mensajes para CEK/CMK placeholders y los archivos de auditoría.';
GO
