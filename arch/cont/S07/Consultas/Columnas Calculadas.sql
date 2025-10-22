-- 1. Calcular el valor total del inventario por artículo (Stock x Precio Proveedor)
SELECT DescripcionArticulo, StockActual, PrecioProveedor, 
       (StockActual * PrecioProveedor) AS ValorTotalInventario
FROM ARTICULO;

-- 2. Mostrar el precio de venta de un artículo con un aumento del 30%
SELECT DescripcionArticulo, PrecioProveedor,
       (PrecioProveedor * 1.30) AS PrecioConAumento
FROM ARTICULO;

-- 3. Calcular el costo total por artículo en cada orden de compra
SELECT NumOrden, CodArticulo, PrecioCompra, CantidadSolicitada,
       (PrecioCompra * CantidadSolicitada) AS CostoTotal
FROM ORDEN_DETALLE;

-- 4. Mostrar la información del proveedor concatenando dirección, ciudad y departamento
SELECT NomProveedor,
       Direccion + ', ' + Ciudad + ', ' + Departamento AS DireccionCompleta
FROM PROVEEDOR;

-- 5. Calcular el valor total de los artículos enviados en cada guía de detalle
SELECT NumGuia, CodArticulo, PrecioVenta, CantidadEnviada,
       (PrecioVenta * CantidadEnviada) AS ValorTotalEnviado
FROM GUIA_DETALLE;

-- 6. Simular un aumento del 10% en el precio de todos los artículos
SELECT DescripcionArticulo, PrecioProveedor,
       (PrecioProveedor * 1.10) AS PrecioConAumento10
FROM ARTICULO;

-- 7. Mostrar la diferencia entre la cantidad solicitada y la recibida en las órdenes de compra
SELECT NumOrden, CodArticulo, CantidadSolicitada, CantidadRecibida,
       (CantidadSolicitada - ISNULL(CantidadRecibida, 0)) AS Diferencia
FROM ORDEN_DETALLE;

-- 8. Indicar el nivel de stock respecto al mínimo (StockActual - StockMínimo)
SELECT DescripcionArticulo, StockActual, StockMinimo,
       (StockActual - StockMinimo) AS NivelStock
FROM ARTICULO;

-- 9. Mostrar el nombre de la línea de producto en mayúsculas
SELECT UPPER(NomLinea) AS NombreMayusculas, Descripcion
FROM LINEA;

-- 10. Concatenar el código y nombre del proveedor en una sola columna
SELECT CAST(CodProveedor AS VARCHAR) + ' - ' + NomProveedor AS CodigoYNombre
FROM PROVEEDOR;