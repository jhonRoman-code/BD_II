-- 1. Encontrar proveedores que no tienen registrado un fax
SELECT * FROM PROVEEDOR 
WHERE Fax IS NULL OR Fax = '';

-- 2. Listar las órdenes de compra que todavía no han ingresado (FechaIngreso es nula)
SELECT * FROM ORDEN_COMPRA 
WHERE FechaIngreso IS NULL;

-- 3. Mostrar los artículos que no tienen definida una presentación
SELECT * FROM ARTICULO 
WHERE Presentacion IS NULL OR Presentacion = '';

-- 4. Seleccionar detalles de orden donde la cantidad recibida aún no se ha registrado
SELECT * FROM ORDEN_DETALLE 
WHERE CantidadRecibida IS NULL;

-- 5. Encontrar proveedores cuyo representante no está especificado
SELECT * FROM PROVEEDOR 
WHERE Representante IS NULL OR Representante = '';

-- 6. Listar todos los proveedores que SÍ tienen un número de fax
SELECT * FROM PROVEEDOR 
WHERE Fax IS NOT NULL AND Fax != '';

-- 7. Mostrar las órdenes de compra que ya tienen una fecha de ingreso registrada
SELECT * FROM ORDEN_COMPRA 
WHERE FechaIngreso IS NOT NULL;

-- 8. Buscar artículos cuyo precio de proveedor no está definido
SELECT * FROM ARTICULO 
WHERE PrecioProveedor IS NULL;

-- 9. Encontrar proveedores para los cuales no se ha registrado un código postal
SELECT * FROM PROVEEDOR 
WHERE CodigoPostal IS NULL OR CodigoPostal = '';

-- 10. Mostrar los detalles de órdenes cuyo estado no ha sido definido
SELECT * FROM ORDEN_DETALLE 
WHERE Estado IS NULL OR Estado = '';