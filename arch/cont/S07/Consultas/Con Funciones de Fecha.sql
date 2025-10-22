-- 1. Mostrar el año en que se realizó cada orden de compra
SELECT NumOrden, YEAR(FechaOrden) AS AñoOrden 
FROM ORDEN_COMPRA;

-- 2. Obtener el mes y día de salida de las guías de envío
SELECT NumGuia, MONTH(FechaSalida) AS Mes, DAY(FechaSalida) AS Dia 
FROM GUIA_ENVIO;

-- 3. Calcular cuántos días tardó en llegar cada orden de compra
SELECT NumOrden, FechaOrden, FechaIngreso,
       DATEDIFF(DAY, FechaOrden, FechaIngreso) AS DiasTranscurridos
FROM ORDEN_COMPRA 
WHERE FechaIngreso IS NOT NULL;

-- 4. Mostrar el nombre del día de la semana en que se generó cada orden
SELECT NumOrden, FechaOrden,
       DATENAME(WEEKDAY, FechaOrden) AS DiaSemana
FROM ORDEN_COMPRA;

-- 5. Listar las órdenes de compra realizadas en el mes actual
SELECT * FROM ORDEN_COMPRA 
WHERE YEAR(FechaOrden) = YEAR(GETDATE()) 
AND MONTH(FechaOrden) = MONTH(GETDATE());

-- 6. Agregar 15 días a la fecha de salida de una guía para estimar una fecha de entrega
SELECT NumGuia, FechaSalida,
       DATEADD(DAY, 15, FechaSalida) AS FechaEstimadaEntrega
FROM GUIA_ENVIO;

-- 7. Obtener la fecha actual del servidor de base de datos
SELECT GETDATE() AS FechaActualServidor;

-- 8. Mostrar las guías de envío del último trimestre
SELECT * FROM GUIA_ENVIO 
WHERE FechaSalida >= DATEADD(QUARTER, -1, GETDATE());

-- 9. Extraer la parte de la fecha (sin la hora) de las órdenes de compra
SELECT NumOrden, CAST(FechaOrden AS DATE) AS FechaSinHora 
FROM ORDEN_COMPRA;

-- 10. Formatear la fecha de las órdenes al estilo dd/MM/yyyy
SELECT NumOrden, 
       FORMAT(FechaOrden, 'dd/MM/yyyy') AS FechaFormateada
FROM ORDEN_COMPRA;