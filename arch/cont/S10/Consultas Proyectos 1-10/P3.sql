-- Proyecto 3: Definición de modelo de recuperación y respaldo para QhatuPeruNuevo

-- Ejercicio a) Cambia el modelo de recuperación de QhatuPeruNuevo a Simple y luego a Bulk-Logged

-- Cambiar el modelo de recuperación a Simple
ALTER DATABASE QhatuPeruNuevo SET RECOVERY SIMPLE;
GO

-- Cambiar el modelo de recuperación a Bulk-Logged
ALTER DATABASE QhatuPeruNuevo SET RECOVERY BULK_LOGGED;
GO

-- Ejercicio b) Realiza un respaldo completo después de cambiar al modelo FULL

-- Cambiar el modelo de recuperación a FULL para permitir respaldos completos
ALTER DATABASE QhatuPeruNuevo SET RECOVERY FULL;
GO

-- Realizar un respaldo completo de la base de datos
BACKUP DATABASE QhatuPeruNuevo TO DISK = 'C:\QhatuPeru\QhatuPeruNuevo_Full.bak';
GO
