-- 1. Seleccionar artículos que pertenezcan a las líneas de producto 1, 3 y 5
SELECT * FROM ARTICULO 
WHERE CodLinea IN (1, 3, 5);

-- 2. Listar los proveedores de las ciudades de 'Lima', 'Callao'
SELECT * FROM PROVEEDOR 
WHERE Ciudad IN ('Lima', 'Callao');

-- 3. Mostrar las órdenes de detalle con estado 'COMPLETADO' o 'PENDIENTE'
SELECT * FROM ORDEN_DETALLE 
WHERE Estado IN ('COMPLETADO', 'PENDIENTE');

-- 4. Encontrar las tiendas con los códigos 2, 4 y 6
SELECT * FROM TIENDA 
WHERE CodTienda IN (2, 4, 6);

-- 5. Obtener las guías de envío gestionadas por los transportistas 1 y 3
SELECT * FROM GUIA_ENVIO 
WHERE CodTransportista IN (1, 3);

-- 6. Buscar artículos de los proveedores con códigos 1, 2 y 3
SELECT * FROM ARTICULO 
WHERE CodProveedor IN (1, 2, 3);

-- 7. Seleccionar los detalles de las órdenes de compra 1001, 1005 y 1010
SELECT * FROM ORDEN_DETALLE 
WHERE NumOrden IN (1001, 1005, 1010);

-- 8. Listar proveedores que NO sean de Lima o Callao
SELECT * FROM PROVEEDOR 
WHERE Ciudad NOT IN ('Lima', 'Callao');

-- 9. Mostrar los artículos cuya presentación sea 'Botella' o 'Caja'
SELECT * FROM ARTICULO 
WHERE Presentacion IN ('Botella', 'Caja');

-- 10. Obtener las guías de detalle para los artículos con códigos 1, 3 y 5
SELECT * FROM GUIA_DETALLE 
WHERE CodArticulo IN (1, 3, 5);