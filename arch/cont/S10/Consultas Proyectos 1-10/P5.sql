-- Ejercicio a) Otorgar a GerenteQhatu acceso exclusivo (solo SELECT) a la tabla Ventas
-- 1. Crear el login para GerenteQhatu a nivel de servidor
CREATE LOGIN GerenteQhatu WITH PASSWORD = 'Password123';
GO
-- 2. Crear el usuario GerenteQhatu en la base de datos QhatuPeruNuevo
USE QhatuPeruNuevo;
CREATE USER GerenteQhatu FOR LOGIN GerenteQhatu;
GO
-- 3. Asignar al usuario GerenteQhatu el rol db_datareader para permitir la lectura de la base de datos
EXEC sp_addrolemember 'db_datareader', 'GerenteQhatu';
GO

-- Ejercicio b) Restringir a CajeroQhatu de realizar cualquier cambio en la tabla Ventas

-- 4. Crear el login para CajeroQhatu a nivel de servidor
CREATE LOGIN CajeroQhatu WITH PASSWORD = 'Password456';
GO

-- 5. Crear el usuario CajeroQhatu en la base de datos QhatuPeruNuevo
USE QhatuPeruNuevo;
CREATE USER CajeroQhatu FOR LOGIN CajeroQhatu;
GO

-- 6. Revocar todos los permisos de CajeroQhatu sobre la tabla Ventas para evitar cambios
REVOKE ALL PRIVILEGES ON dbo.Ventas TO CajeroQhatu;
GO
