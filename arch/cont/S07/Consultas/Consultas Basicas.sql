-- 1. Listar todas las tiendas
SELECT * FROM TIENDA;

-- 2. Obtener el nombre y representante de todos los proveedores
SELECT NomProveedor, Representante FROM PROVEEDOR;

-- 3. Mostrar todas las líneas de productos con su descripción
SELECT NomLinea, Descripcion FROM LINEA;

-- 4. Ver la descripción y el stock actual de todos los artículos
SELECT DescripcionArticulo, StockActual FROM ARTICULO;

-- 5. Listar todos los transportistas y sus números de teléfono
SELECT NomTransportista, Telefono FROM TRANSPORTISTA;

-- 6. Obtener los números de todas las órdenes de compra y sus fechas
SELECT NumOrden, FechaOrden FROM ORDEN_COMPRA;

-- 7. Mostrar el código de la tienda y la fecha de salida de todas las guías de envío
SELECT CodTienda, FechaSalida FROM GUIA_ENVIO;

-- 8. Ver los detalles de las órdenes: número de orden, artículo y cantidad solicitada
SELECT NumOrden, CodArticulo, CantidadSolicitada FROM ORDEN_DETALLE;

-- 9. Listar la dirección y ciudad de todos los proveedores
SELECT Direccion, Ciudad FROM PROVEEDOR;

-- 10. Mostrar los detalles de las guías: número de guía, artículo y cantidad enviada
SELECT NumGuia, CodArticulo, CantidadEnviada FROM GUIA_DETALLE;