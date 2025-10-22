-- 1. Seleccionar artículos con un stock actual entre 20 y 50 unidades
SELECT * FROM ARTICULO 
WHERE StockActual BETWEEN 20 AND 50;

-- 2. Listar las órdenes de compra realizadas en septiembre de 2024
SELECT * FROM ORDEN_COMPRA 
WHERE FechaOrden BETWEEN '2024-09-01' AND '2024-09-30';

-- 3. Obtener artículos cuyo precio de proveedor esté entre 10 y 25
SELECT * FROM ARTICULO 
WHERE PrecioProveedor BETWEEN 10 AND 25;

-- 4. Mostrar las guías de envío con códigos entre 2001 y 2005
SELECT * FROM GUIA_ENVIO 
WHERE NumGuia BETWEEN 2001 AND 2005;

-- 5. Encontrar proveedores cuyos nombres (alfabéticamente) están entre 'A' y 'L'
SELECT * FROM PROVEEDOR 
WHERE NomProveedor BETWEEN 'A' AND 'M';

-- 6. Listar detalles de órdenes con cantidad solicitada entre 50 y 100
SELECT * FROM ORDEN_DETALLE 
WHERE CantidadSolicitada BETWEEN 50 AND 100;

-- 7. Buscar tiendas con códigos entre 1 y 5
SELECT * FROM TIENDA 
WHERE CodTienda BETWEEN 1 AND 5;

-- 8. Mostrar guías de detalle con un precio de venta entre 15 y 30
SELECT * FROM GUIA_DETALLE 
WHERE PrecioVenta BETWEEN 15 AND 30;

-- 9. Seleccionar artículos cuyo código de línea esté entre 1 y 3
SELECT * FROM ARTICULO 
WHERE CodLinea BETWEEN 1 AND 3;

-- 10. Listar proveedores cuyo código postal esté en un rango específico
SELECT * FROM PROVEEDOR 
WHERE CodigoPostal BETWEEN '15000' AND '15999';