
-- Ejercicio a) Consulta las propiedades actuales, modifica la colación y configura el crecimiento automático del archivo principal
USE master;
GO

-- Cambiar la base de datos a modo único para asegurarse de que no haya conexiones activas
ALTER DATABASE QhatuPeruNuevo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Consultar las propiedades actuales de la base de datos
SELECT DATABASEPROPERTYEX('QhatuPeruNuevo', 'Collation');
GO

-- Cambiar la colación de la base de datos a Latin1_General_CI_AS para soportar caracteres con tildes y mejorar la compatibilidad con el idioma español
ALTER DATABASE QhatuPeruNuevo COLLATE Latin1_General_CI_AS;
GO

-- Modificar el crecimiento automático del archivo principal de datos a 10 MB
ALTER DATABASE QhatuPeruNuevo 
MODIFY FILE (NAME = 'QhatuPeruNuevo_Data', FILEGROWTH = 10MB);
GO

-- Ejercicio b) Modifica el crecimiento automático del archivo primario de datos a 20 MB

-- Modificar el crecimiento automático del archivo principal de datos a 20 MB
ALTER DATABASE QhatuPeruNuevo 
MODIFY FILE (NAME = 'QhatuPeruNuevo_Data', FILEGROWTH = 20MB);
GO

-- Restaurar el acceso multiusuario después de realizar los cambios
ALTER DATABASE QhatuPeruNuevo SET MULTI_USER;
GO
