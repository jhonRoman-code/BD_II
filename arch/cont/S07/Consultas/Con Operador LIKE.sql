-- 1. Buscar todos los artículos cuya descripción comience con "Leche"
SELECT * FROM ARTICULO 
WHERE DescripcionArticulo LIKE 'Leche%';

-- 2. Encontrar proveedores cuyo nombre contenga la palabra 'SAC'
SELECT * FROM PROVEEDOR 
WHERE NomProveedor LIKE '%SAC%';

-- 3. Listar las líneas de productos que terminen en 's'
SELECT * FROM LINEA 
WHERE NomLinea LIKE '%s';

-- 4. Obtener las tiendas cuya dirección contenga 'Av.'
SELECT * FROM TIENDA 
WHERE Direccion LIKE '%Av.%';

-- 5. Buscar artículos cuya presentación sea en 'Caja'
SELECT * FROM ARTICULO 
WHERE Presentacion LIKE '%Caja%';

-- 6. Encontrar proveedores cuyo representante se llame 'Ana'
SELECT * FROM PROVEEDOR 
WHERE Representante LIKE 'Ana%';

-- 7. Listar transportistas cuyo nombre comience con una letra entre 'A' y 'C'
SELECT * FROM TRANSPORTISTA 
WHERE NomTransportista LIKE '[A-C]%';

-- 8. Buscar artículos cuya descripción tenga exactamente 5 letras
SELECT * FROM ARTICULO 
WHERE DescripcionArticulo LIKE '_____';

-- 9. Encontrar proveedores de un distrito que empiece con 'San'
SELECT * FROM PROVEEDOR 
WHERE Ciudad LIKE 'San%';

-- 10. Mostrar líneas de productos que no contengan la palabra 'Lácteos'
SELECT * FROM LINEA 
WHERE NomLinea NOT LIKE '%Lácteos%';