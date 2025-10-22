
USE QhatuPERU;
GO

-- Tabla TIENDA
CREATE TABLE TIENDA (
    CodTienda INT NOT NULL PRIMARY KEY,
    Direccion VARCHAR(60),
    Distrito VARCHAR(20),
    Telefono VARCHAR(15),
    Fax VARCHAR(15)
);
GO

-- Tabla LINEA
CREATE TABLE LINEA (
    CodLinea INT IDENTITY(1,1) PRIMARY KEY,
    NomLinea VARCHAR(20) NOT NULL,
    Descripcion VARCHAR(40),
    CONSTRAINT U_Linea_NomLinea UNIQUE(NomLinea)
);
GO

-- Tabla PROVEEDOR
CREATE TABLE PROVEEDOR (
    CodProveedor INT IDENTITY(1,1) PRIMARY KEY,
    NomProveedor VARCHAR(40) NOT NULL,
    Representante VARCHAR(30),
    Direccion VARCHAR(60),
    Ciudad VARCHAR(15),
    Departamento VARCHAR(15),
    CodigoPostal VARCHAR(15),
    Telefono VARCHAR(15),
    Fax VARCHAR(15)
);
GO

-- Tabla ARTICULO
CREATE TABLE ARTICULO (
    CodArticulo INT IDENTITY PRIMARY KEY,
    CodLinea INT NOT NULL,
    CodProveedor INT NOT NULL,
    DescripcionArticulo VARCHAR(40) NOT NULL,
    Presentacion VARCHAR(30),
    PrecioProveedor MONEY,
    StockActual SMALLINT,
    StockMinimo SMALLINT,
    Descontinuado BIT DEFAULT 0,
    CONSTRAINT CK_Articulo_PrecioProveedor CHECK (PrecioProveedor >= 0),
    CONSTRAINT FK_Articulo_Linea FOREIGN KEY (CodLinea) REFERENCES LINEA(CodLinea) ON DELETE CASCADE,
    CONSTRAINT FK_Articulo_Proveedor FOREIGN KEY (CodProveedor) REFERENCES PROVEEDOR(CodProveedor)
);
GO

-- Tabla ORDEN_COMPRA
CREATE TABLE ORDEN_COMPRA (
    NumOrden INT NOT NULL PRIMARY KEY,
    FechaOrden DATETIME NOT NULL,
    FechaIngreso DATETIME
);
GO

-- Tabla ORDEN_DETALLE
CREATE TABLE ORDEN_DETALLE (
    NumOrden INT NOT NULL,
    CodArticulo INT NOT NULL,
    PrecioCompra MONEY NOT NULL,
    CantidadSolicitada SMALLINT NOT NULL,
    CantidadRecibida SMALLINT,
    Estado VARCHAR(10),
    CONSTRAINT PK_ORDEN_DETALLE PRIMARY KEY (NumOrden, CodArticulo),
    CONSTRAINT FK_OrdenDetalle_Orden FOREIGN KEY (NumOrden) REFERENCES ORDEN_COMPRA(NumOrden),
    CONSTRAINT FK_OrdenDetalle_Articulo FOREIGN KEY (CodArticulo) REFERENCES ARTICULO(CodArticulo)
);
GO

-- Tabla TRANSPORTISTA
CREATE TABLE TRANSPORTISTA (
    CodTransportista INT NOT NULL PRIMARY KEY,
    NomTransportista VARCHAR(30) NOT NULL,
    Direccion VARCHAR(60),
    Telefono VARCHAR(15)
);
GO

-- Tabla GUIA_ENVIO
CREATE TABLE GUIA_ENVIO (
    NumGuia INT NOT NULL PRIMARY KEY,
    CodTienda INT NOT NULL,
    FechaSalida DATETIME NOT NULL,
    CodTransportista INT NOT NULL,
    CONSTRAINT FK_GuiaEnvio_Tienda FOREIGN KEY (CodTienda) REFERENCES TIENDA(CodTienda),
    CONSTRAINT FK_GuiaEnvio_Transportista FOREIGN KEY (CodTransportista) REFERENCES TRANSPORTISTA(CodTransportista)
);
GO

-- Tabla GUIA_DETALLE
CREATE TABLE GUIA_DETALLE (
    NumGuia INT NOT NULL,
    CodArticulo INT NOT NULL,
    PrecioVenta MONEY NOT NULL,
    CantidadEnviada SMALLINT NOT NULL,
    CONSTRAINT PK_GUIA_DETALLE PRIMARY KEY (NumGuia, CodArticulo),
    CONSTRAINT FK_GuiaDetalle_Guia FOREIGN KEY (NumGuia) REFERENCES GUIA_ENVIO(NumGuia),
    CONSTRAINT FK_GuiaDetalle_Articulo FOREIGN KEY (CodArticulo) REFERENCES ARTICULO(CodArticulo)
);
GO
