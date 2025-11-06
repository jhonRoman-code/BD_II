-- Crear la tabla AuditoriaClientes para registrar cambios en Clientes
CREATE TABLE AuditoriaClientes (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT,
    Nombre NVARCHAR(100),
    Correo NVARCHAR(100),
    Telefono NVARCHAR(15),
    Accion NVARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    FechaModificacion DATETIME DEFAULT GETDATE(),
    Usuario NVARCHAR(50)
);
GO

-- Crear un trigger para registrar eliminaciones en la tabla AuditoriaClientes
CREATE TRIGGER Trg_AuditoriaEliminarClientes
ON Clientes
INSTEAD OF DELETE
AS
BEGIN
    -- Insertar los registros eliminados en la tabla AuditoriaClientes
    INSERT INTO AuditoriaClientes (ClienteID, Nombre, Correo, Telefono, Accion, Usuario)
    SELECT ClienteID, Nombre, Correo, Telefono, 'DELETE', SYSTEM_USER
    FROM deleted;

    -- Eliminar el registro de la tabla Clientes
    DELETE FROM Clientes WHERE ClienteID IN (SELECT ClienteID FROM deleted);
END;
GO
