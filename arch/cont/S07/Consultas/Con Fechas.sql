-- 1. Seleccionar todas las órdenes de compra realizadas en una fecha específica
SELECT * FROM ORDEN_COMPRA WHERE CAST(FechaOrden AS DATE) = '2024-01-15';

-- 2. Listar las guías de envío que salieron antes del 1 de enero de 2025
SELECT * FROM GUIA_ENVIO WHERE FechaSalida < '2025-01-01';

-- 3. Encontrar las órdenes de compra que aún no han ingresado (FechaIngreso es nula)
SELECT * FROM ORDEN_COMPRA WHERE FechaIngreso IS NULL;

-- 4. Mostrar las órdenes de compra del mes de septiembre de 2024
SELECT * FROM ORDEN_COMPRA 
WHERE YEAR(FechaOrden) = 2024 AND MONTH(FechaOrden) = 9;

-- 5. Listar las guías de envío de la última semana
SELECT * FROM GUIA_ENVIO 
WHERE FechaSalida >= DATEADD(DAY, -7, GETDATE());

-- 6. Obtener las órdenes de compra cuya fecha de ingreso fue posterior a la fecha del pedido
SELECT * FROM ORDEN_COMPRA 
WHERE FechaIngreso > FechaOrden;

-- 7. Buscar las órdenes de compra realizadas en el primer trimestre de 2024
SELECT * FROM ORDEN_COMPRA 
WHERE YEAR(FechaOrden) = 2024 AND MONTH(FechaOrden) BETWEEN 1 AND 3;

-- 8. Mostrar las guías de envío que salieron exactamente hoy
SELECT * FROM GUIA_ENVIO 
WHERE CAST(FechaSalida AS DATE) = CAST(GETDATE() AS DATE);

-- 9. Listar las órdenes de compra del año 2024
SELECT * FROM ORDEN_COMPRA 
WHERE YEAR(FechaOrden) = 2024;

-- 10. Encontrar las órdenes que tardaron más de 10 días en ingresar
SELECT * FROM ORDEN_COMPRA 
WHERE FechaIngreso IS NOT NULL 
AND DATEDIFF(DAY, FechaOrden, FechaIngreso) > 10;