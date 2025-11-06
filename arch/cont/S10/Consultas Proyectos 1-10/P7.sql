-- Eliminar registros de la tabla Sesiones con más de 15 días de antigüedad
DELETE FROM Sesiones
WHERE FechaSesion < DATEADD(DAY, -15, GETDATE());
GO
