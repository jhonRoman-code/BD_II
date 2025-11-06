-- Consultar los archivos físicos asociados a la base de datos QhatuPeruNuevo
USE QhatuPeruNuevo;
SELECT name, physical_name AS FileLocation, type_desc
FROM sys.database_files;
GO
