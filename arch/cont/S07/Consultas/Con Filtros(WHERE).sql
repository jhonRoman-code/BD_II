-- 1. Encontrar todos los artículos cuyo stock actual sea menor a 10
SELECT * FROM ARTICULO WHERE StockActual < 10;

-- 2. Listar los proveedores de la ciudad de 'Lima'
SELECT * FROM PROVEEDOR WHERE Ciudad = 'Lima';

-- 3. Mostrar las órdenes de compra con estado 'Pendiente'
SELECT * FROM ORDEN_DETALLE WHERE Estado = 'Pendiente';

-- 4. Obtener los artículos descontinuados (Descontinuado = 1)
SELECT * FROM ARTICULO WHERE Descontinuado = 1;

-- 5. Buscar las guías de envío gestionadas por el transportista con código 1
SELECT * FROM GUIA_ENVIO WHERE CodTransportista = 1;

-- 6. Listar los artículos con un precio de proveedor mayor a 50
SELECT * FROM ARTICULO WHERE PrecioProveedor > 50;

-- 7. Encontrar las tiendas ubicadas en el distrito de 'Miraflores'
SELECT * FROM TIENDA WHERE Distrito = 'Miraflores';

-- 8. Mostrar detalles de órdenes donde la cantidad solicitada fue mayor a 100 unidades
SELECT * FROM ORDEN_DETALLE WHERE CantidadSolicitada > 100;

-- 9. Listar las líneas de productos que no sean 'Bebidas'
SELECT * FROM LINEA WHERE NomLinea != 'Bebidas';

-- 10. Obtener los proveedores que no tienen un fax registrado
SELECT * FROM PROVEEDOR WHERE Fax IS NULL OR Fax = '';