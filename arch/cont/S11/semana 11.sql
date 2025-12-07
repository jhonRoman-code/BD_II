-- 1. Crear un Login de SQL Server (Práctica: Usar una contraseña fuerte)
CREATE LOGIN [UsuarioSQL] WITH PASSWORD = 'Contraseña_Fuerte!2025', CHECK_POLICY = ON;
GO

-- 2. Crear un Login de Windows (Práctica: Preferido por seguridad)
-- Reemplazar 'DOMINIO\NombreUsuario' con tu usuario de Windows/Dominio
CREATE LOGIN [Aurora\frank] FROM WINDOWS;
GO

--si ya lo tienes creado simplemente asígnale acceso a la base de datos
USE QhatuPERU;
CREATE USER [Aurora\frank] FOR LOGIN [Aurora\frank];
ALTER ROLE db_datareader ADD MEMBER [Aurora\frank];
ALTER ROLE db_datawriter ADD MEMBER [Aurora\frank];

--2
-- Obtener la cuenta de servicio actual que está ejecutando la instancia de SQL Server
SELECT 
    servicename,
    service_account,
    instant_file_initialization_enabled
FROM 
    sys.dm_server_services
WHERE 
    servicename LIKE '%' + CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(100)) + '%';

--3
USE [QhatuPERU]; -- Asegúrate de estar en la base de datos correcta
GO

-- 1. Crear el rol personalizado de base de datos
CREATE ROLE [RolLecturaInformes];
GO

-- 2. Asignar el permiso específico al rol
-- En este caso, permiso para solo leer (SELECT) en la tabla de Informes
GRANT SELECT ON [dbo].[Informes] TO [RolLecturaInformes];
GO

-- 3. Agregar un usuario al nuevo rol
ALTER ROLE [RolLecturaInformes] ADD MEMBER [UsuarioSQL]; -- Usa un usuario ya creado

--4
USE [QhatuPERU];
GO

-- 1. Otorgar permiso de INSERT (GRANT)
GRANT INSERT ON [dbo].[Ventas] TO [UsuarioSQL]; 
GO

-- 2. Denegar explícitamente permiso de DELETE (DENY)
-- Esto asegura que el usuario no pueda borrar, incluso si es miembro de un rol que tiene DELETE.
DENY DELETE ON [dbo].[Ventas] TO [UsuarioSQL]; 
GO

-- 3. Revocar el permiso de INSERT (si se quiere quitar)
REVOKE INSERT ON [dbo].[Ventas] TO [UsuarioSQL];

--5
USE master;
GO

-- Crear una Master Key si no existe
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ClaveSegura_123!';
    PRINT 'Clave maestra creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La clave maestra ya existe.';
END
GO

-- ===========================================
-- Paso 2: Crear un Certificado para TDE
-- ===========================================
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'TechGadget_Cert')
BEGIN
    CREATE CERTIFICATE TechGadget_Cert
    WITH SUBJECT = 'Certificado de Cifrado para TechGadgetStore';
    PRINT 'Certificado creado correctamente.';
END
ELSE
BEGIN
    PRINT 'El certificado TechGadget_Cert ya existe.';
END
GO

-- ===========================================
-- Paso 3: Crear la Clave de Cifrado de la Base de Datos
-- ===========================================
USE TechGadgetStore;
GO

IF NOT EXISTS (SELECT * FROM sys.dm_database_encryption_keys)
BEGIN
    CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TechGadget_Cert;
    PRINT 'Clave de cifrado de base de datos creada correctamente.';
END
ELSE
BEGIN
    PRINT 'La clave de cifrado de base de datos ya existe.';
END
GO

-- ===========================================
-- Paso 4: Habilitar TDE en la Base de Datos
-- ===========================================
USE master;
GO

DECLARE @estado INT;
SELECT @estado = encryption_state FROM sys.dm_database_encryption_keys
WHERE database_id = DB_ID('TechGadgetStore');

IF @estado IS NULL OR @estado <> 3
BEGIN
    ALTER DATABASE TechGadgetStore SET ENCRYPTION ON;
    PRINT 'Cifrado TDE habilitado correctamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos ya está cifrada.';
END
GO

-- ===========================================
-- Paso 5: Verificación del Cifrado
-- ===========================================
SELECT
    name AS NombreBaseDatos,
    is_encrypted AS EstaCifrada
FROM sys.databases
WHERE name = 'TechGadgetStore';
GO
--6
-- 1. Crear el objeto de SQL Server Audit
-- Reemplaza 'C:\Audit\' con un directorio seguro y existente
CREATE SERVER AUDIT [Audit_Server_Logins]
TO FILE 
(    FILEPATH = 'C:\Audit\'
    ,MAXSIZE = 10 MB
    ,MAX_ROLLOVER_FILES = 5
    ,RESERVE_DISK_SPACE = OFF
)
WITH 
(    QUEUE_DELAY = 1000
    ,ON_FAILURE = CONTINUE -- CONTINUAR la operación si la auditoría falla
);
GO

-- 2. Habilitar el Audit
ALTER SERVER AUDIT [Audit_Server_Logins] WITH (STATE = ON);
--practica 1 
-- 1. Crear la Especificación de Auditoría de Servidor
CREATE SERVER AUDIT SPECIFICATION [Login_Attempts_Spec]
FOR SERVER AUDIT [Audit_Server_Logins] 
ADD (SUCCESSFUL_LOGIN_GROUP), -- Para inicios de sesión exitosos
ADD (FAILED_LOGIN_GROUP)      -- Para intentos de inicio de sesión fallidos
WITH (STATE = ON);
GO

-- 2. Verificar que la especificación está activa
SELECT * FROM sys.server_audit_specifications WHERE name = 'Login_Attempts_Spec';

--2 
USE [QhatuPERU]; 
GO

-- 1. Crear la Clave Maestra de Columna (CMK)
-- (La clave real reside en un almacén de claves como Azure Key Vault o un almacén de certificados)
CREATE COLUMN MASTER KEY [CMK_AlwaysEncrypted]
WITH (
    KEY_STORE_PROVIDER_NAME = 'MSSQL_CERTIFICATE_STORE', -- Ejemplo: Usando Certificado
    KEY_PATH = 'Certificado_CN' -- El nombre común (CN) del certificado
);
GO

-- 2. Crear la Clave de Cifrado de Columna (CEK)
CREATE COLUMN ENCRYPTION KEY [CEK_DNI]
WITH VALUES (
    COLUMN_MASTER_KEY = [CMK_AlwaysEncrypted],
    ALGORITHM = 'RSA_OAEP', -- Algoritmo de cifrado
    ENCRYPTED_VALUE = 0x... -- Este valor se genera usando SSMS o PowerShell
);
GO

-- 3. Modificar la tabla para cifrar la columna 'NumeroDNI'
ALTER TABLE [dbo].[Clientes]
ALTER COLUMN [NumeroDNI] NVARCHAR(20) 
ENCRYPTED WITH (
    COLUMN_ENCRYPTION_KEY = [CEK_DNI],
    ENCRYPTION_TYPE = DETERMINISTIC, -- Permite búsquedas de igualdad
    -- ENCRYPTION_TYPE = RANDOMIZED, -- Mejor seguridad, no permite búsquedas
    -- (El tipo de dato debe ser consistente con el cifrado)
    -- Tipo de dato para cifrado
    -- Note: El cifrado cambia el tipo de dato subyacente a VARBINARY
    -- Esto se hace típicamente con el asistente de SSMS o PowerShell. 
    -- Este código es solo indicativo de la definición de cifrado.
);