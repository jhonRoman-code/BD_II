-- Ejercicio a) Crea el usuario VendedorQhatu y asignalo al rol db_datawriter para registrar ventas

-- 1. Crear el login para VendedorQhatu a nivel de servidor
CREATE LOGIN VendedorQhatu WITH PASSWORD = 'Password123';
GO

-- 2. Crear el usuario VendedorQhatu en la base de datos QhatuPeruNuevo
USE QhatuPeruNuevo;
CREATE USER VendedorQhatu FOR LOGIN VendedorQhatu;
GO

-- 3. Asignar al usuario VendedorQhatu el rol db_datawriter para permitir la escritura en la base de datos
EXEC sp_addrolemember 'db_datawriter', 'VendedorQhatu';
GO

-- Ejercicio b) Crea el usuario ConsultaCliente y asignalo al rol db_datareader para solo leer datos

-- 4. Crear el login para ConsultaCliente a nivel de servidor
CREATE LOGIN ConsultaCliente WITH PASSWORD = 'Password456';
GO

-- 5. Crear el usuario ConsultaCliente en la base de datos QhatuPeruNuevo
USE QhatuPeruNuevo;
CREATE USER ConsultaCliente FOR LOGIN ConsultaCliente;
GO

-- 6. Asignar al usuario ConsultaCliente el rol db_datareader para permitir solo la lectura de los datos
EXEC sp_addrolemember 'db_datareader', 'ConsultaCliente';
GO
