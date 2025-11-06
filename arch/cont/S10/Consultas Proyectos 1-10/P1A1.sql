USE QhatuPeruNuevo;
GO

-- Paso 3: Crear las tablas necesarias

-- Crear la tabla Clientes
CREATE TABLE Clientes (
    ClienteId INT IDENTITY PRIMARY KEY,  -- Identificador único para cada cliente
    Nombre VARCHAR(100),                 -- Nombre del cliente
    Email VARCHAR(100),                  -- Correo electrónico del cliente
    Telefono VARCHAR(20),                -- Teléfono del cliente
    Direccion VARCHAR(255),              -- Dirección del cliente
    FechaRegistro DATETIME DEFAULT GETDATE()  -- Fecha de registro (automática)
);
GO

-- Crear la tabla Ventas
CREATE TABLE Ventas (
    VentaId INT IDENTITY PRIMARY KEY,   -- Identificador único de la venta
    ClienteId INT,                      -- ID del cliente que realizó la venta
    Monto DECIMAL(10, 2),                -- Monto total de la venta
    FechaVenta DATETIME DEFAULT GETDATE(),  -- Fecha de la venta (automática)
    FOREIGN KEY (ClienteId) REFERENCES Clientes(ClienteId)  -- Relación con la tabla Clientes
);
GO

-- Crear la tabla Pedidos
CREATE TABLE Pedidos (
    PedidoId INT IDENTITY PRIMARY KEY,  -- Identificador único del pedido
    ClienteId INT,                      -- ID del cliente que realizó el pedido
    FechaPedido DATETIME DEFAULT GETDATE(),  -- Fecha de realización del pedido (automática)
    EstadoPedido VARCHAR(50),            -- Estado del pedido (Ej. 'Pendiente', 'Enviado')
    MontoTotal DECIMAL(10, 2),          -- Monto total del pedido
    FOREIGN KEY (ClienteId) REFERENCES Clientes(ClienteId)  -- Relación con la tabla Clientes
);
GO

-- Crear la tabla AuditoriaClientes
CREATE TABLE AuditoriaClientes (
    Id INT IDENTITY PRIMARY KEY,        -- Identificador único del registro de auditoría
    ClienteId INT,                      -- ID del cliente relacionado
    Modificacion VARCHAR(255),           -- Descripción de la modificación (Ej. 'Eliminado', 'Actualizado')
    Fecha DATETIME DEFAULT GETDATE()    -- Fecha en que se realizó la modificación (automática)
);
GO

-- Paso 4: Insertar datos de ejemplo en las tablas

-- Insertar datos en la tabla Clientes
INSERT INTO Clientes (Nombre, Email, Telefono, Direccion)
VALUES 
('Juan Pérez', 'juan.perez@email.com', '987654321', 'Av. Los Olivos 123'),
('María López', 'maria.lopez@email.com', '912345678', 'Calle Sol 456');
GO

-- Insertar datos en la tabla Ventas
INSERT INTO Ventas (ClienteId, Monto)
VALUES 
(1, 500.00),
(2, 150.75);
GO

-- Insertar datos en la tabla Pedidos
INSERT INTO Pedidos (ClienteId, EstadoPedido, MontoTotal)
VALUES 
(1, 'Pendiente', 250.00),
(2, 'Enviado', 120.50);
GO

-- Paso 5: Consultar las tablas para verificar que todo se haya creado correctamente
SELECT * FROM Clientes;
SELECT * FROM Ventas;
SELECT * FROM Pedidos;
SELECT * FROM AuditoriaClientes;
GO