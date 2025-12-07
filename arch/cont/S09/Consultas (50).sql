USE QhatuPERU;
GO

/*
 I. FUNCIONES DE AGREGACIÓN
*/

-- 1. Mostrar CodArticulo, DescripcionArticulo y ValorInventario
SELECT 
    CodArticulo,
    DescripcionArticulo,
    CAST(StockActual * PrecioProveedor AS DECIMAL(18,2)) AS ValorInventario
FROM ARTICULO;
GO

-- 2. Calcular el total monetario del Inventario
SELECT 
    SUM(StockActual * PrecioProveedor) AS TotalInventario
FROM ARTICULO;
GO

-- 3. Obtener CodLinea y Precio Proveedor promedio
SELECT 
    CodLinea,
    AVG(PrecioProveedor) AS PrecioPromedio
FROM ARTICULO
GROUP BY CodLinea;
GO

-- 4. Contar artículos descontinuados
SELECT 
    COUNT(*) AS TotalDescontinuados
FROM ARTICULO
WHERE Descontinuado = 1;
GO

-- 5. Mostrar Precio Máximo y Precio Mínimo del catálogo
SELECT 
    MAX(PrecioProveedor) AS PrecioMaximo,
    MIN(PrecioProveedor) AS PrecioMinimo
FROM ARTICULO;
GO

-- 6. Mostrar el Valor total contado por guía
SELECT 
    G.NumGuia,
    SUM(D.CantidadEnviada * D.PrecioVenta) AS ValorTotal
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY G.NumGuia;
GO

-- 7. Para cada CodArticulo, mostrar Total Solicitado
SELECT 
    CodArticulo,
    SUM(CantidadSolicitada) AS TotalSolicitado
FROM ORDEN_DETALLE
GROUP BY CodArticulo;
GO

-- 8. Contar órdenes únicos que incluyen cada artículo
SELECT 
    CodArticulo,
    COUNT(DISTINCT NumOrden) AS OrdenesUnicas
FROM ORDEN_DETALLE
GROUP BY CodArticulo;
GO

-- 9. Calcular promedio de días entre FechaOrden y FechaIngreso
SELECT 
    AVG(DATEDIFF(DAY, FechaOrden, FechaIngreso)) AS PromedioDiasIngreso
FROM ORDEN_COMPRA
WHERE FechaIngreso IS NOT NULL;
GO

-- 10. Sumar CantidadEnviada por CodTransportista
SELECT 
    E.CodTransportista,
    SUM(D.CantidadEnviada) AS TotalEnviado
FROM GUIA_ENVIO E
JOIN GUIA_DETALLE D ON E.NumGuia = D.NumGuia
GROUP BY E.CodTransportista;
GO

/* 
 II. CLÁUSULA GROUP BY
 */

-- 11. Mostrar NomLinea y CantArticulos
SELECT 
    L.NomLinea,
    COUNT(A.CodArticulo) AS CantArticulos
FROM LINEA L
JOIN ARTICULO A ON L.CodLinea = A.CodLinea
GROUP BY L.NomLinea;
GO

-- 12. Mostrar CodLinea y StockTotal
SELECT 
    CodLinea,
    SUM(StockActual) AS StockTotal
FROM ARTICULO
GROUP BY CodLinea;
GO

-- 13. Para cada NumOrden, calcular CostoTotal
SELECT 
    NumOrden,
    SUM(PrecioCompra * CantidadSolicitada) AS CostoTotal
FROM ORDEN_DETALLE
GROUP BY NumOrden;
GO

-- 14. Mostrar NumGuia y PromedioEnviado
SELECT 
    NumGuia,
    AVG(CantidadEnviada) AS PromedioEnviado
FROM GUIA_DETALLE
GROUP BY NumGuia;
GO

-- 15. Contar proveedores agrupados por Ciudad
SELECT 
    Ciudad,
    COUNT(CodProveedor) AS TotalProveedores
FROM PROVEEDOR
GROUP BY Ciudad;
GO

-- 16. Mostrar el número de órdenes por día
SELECT 
    CAST(FechaOrden AS DATE) AS Fecha,
    COUNT(*) AS TotalOrdenes
FROM ORDEN_COMPRA
GROUP BY CAST(FechaOrden AS DATE);
GO

-- 17. Sumar (CantidadEnviada * PrecioVenta) por CodTienda
SELECT 
    G.CodTienda,
    SUM(D.CantidadEnviada * D.PrecioVenta) AS TotalVentas
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY G.CodTienda;
GO

-- 18. Mostrar artículos cuyo StockActual promedio ≥ de su CodLinea
SELECT 
    CodLinea,
    AVG(StockActual) AS PromedioStock
FROM ARTICULO
GROUP BY CodLinea
HAVING AVG(StockActual) >= 10;
GO

-- 19. Mostrar CodProveedor, NomProveedor y CantArticulos
SELECT 
    P.CodProveedor,
    P.NomProveedor,
    COUNT(A.CodArticulo) AS CantArticulos
FROM PROVEEDOR P
JOIN ARTICULO A ON P.CodProveedor = A.CodProveedor
GROUP BY P.CodProveedor, P.NomProveedor;
GO

-- 20. Mostrar para cada Estado la suma de CantidadSolicitada
SELECT 
    Estado,
    SUM(CantidadSolicitada) AS TotalSolicitado
FROM ORDEN_DETALLE
GROUP BY Estado;
GO

/*
 III. CLÁUSULA OVER
*/

-- 21. Asignar posición por línea ordenada por precio
SELECT 
    CodLinea,
    CodArticulo,
    PrecioProveedor,
    ROW_NUMBER() OVER (PARTITION BY CodLinea ORDER BY PrecioProveedor DESC) AS Posicion
FROM ARTICULO;
GO

-- 22. Calcular costo por orden y su RANK
SELECT 
    NumOrden,
    SUM(PrecioCompra * CantidadSolicitada) AS CostoTotal,
    RANK() OVER (ORDER BY SUM(PrecioCompra * CantidadSolicitada) DESC) AS RankCosto
FROM ORDEN_DETALLE
GROUP BY NumOrden;
GO

-- 23. Mostrar TotalDía y Acumulado Ventas ordenado por fecha
SELECT 
    CAST(G.FechaSalida AS DATE) AS Fecha,
    SUM(D.CantidadEnviada * D.PrecioVenta) AS TotalDia,
    SUM(SUM(D.CantidadEnviada * D.PrecioVenta)) OVER (ORDER BY CAST(G.FechaSalida AS DATE)) AS Acumulado
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY CAST(G.FechaSalida AS DATE)
ORDER BY Fecha;
GO

-- 24. Calcular promedio móvil para stock
SELECT 
    CodArticulo,
    StockActual,
    AVG(StockActual) OVER (ORDER BY CodArticulo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS PromedioMovil
FROM ARTICULO;
GO

-- 25. Mostrar Precio Anterior Mismo Proveedor usando LAG
SELECT 
    CodProveedor,
    CodArticulo,
    PrecioProveedor,
    LAG(PrecioProveedor) OVER (PARTITION BY CodProveedor ORDER BY CodArticulo) AS PrecioAnterior
FROM ARTICULO;
GO

-- 26. Añadir columna Cantidad Porc.Linea a cada artículo
SELECT 
    CodLinea,
    CodArticulo,
    StockActual,
    CAST(StockActual * 100.0 / SUM(StockActual) OVER (PARTITION BY CodLinea) AS DECIMAL(5,2)) AS PorcentajeLinea
FROM ARTICULO;
GO

-- 27. Mostrar Monto Proveedor y Porcentaje Del Total
SELECT 
    CodProveedor,
    SUM(PrecioProveedor * StockActual) AS MontoProveedor,
    CAST(SUM(PrecioProveedor * StockActual) * 100.0 / SUM(SUM(PrecioProveedor * StockActual)) OVER() AS DECIMAL(5,2)) AS PorcentajeTotal
FROM ARTICULO
GROUP BY CodProveedor;
GO

-- 28. Mostrar solo los 3 artículos más caros por línea
SELECT *
FROM (
    SELECT 
        CodLinea,
        CodArticulo,
        PrecioProveedor,
        ROW_NUMBER() OVER (PARTITION BY CodLinea ORDER BY PrecioProveedor DESC) AS Rn
    FROM ARTICULO
) AS T
WHERE Rn <= 3;
GO

-- 29. Mostrar transportista y su Dense Rank por Total Enviado
SELECT 
    T.CodTransportista,
    SUM(D.CantidadEnviada) AS Total,
    DENSE_RANK() OVER (ORDER BY SUM(D.CantidadEnviada) DESC) AS RankTransporte
FROM TRANSPORTISTA T
JOIN GUIA_ENVIO G ON T.CodTransportista = G.CodTransportista
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY T.CodTransportista;
GO

-- 30. Mostrar por guía la suma acumulada por tienda hasta esa guía
SELECT 
    G.CodTienda,
    G.NumGuia,
    SUM(D.CantidadEnviada * D.PrecioVenta) AS TotalGuia,
    SUM(SUM(D.CantidadEnviada * D.PrecioVenta)) OVER (PARTITION BY G.CodTienda ORDER BY G.FechaSalida) AS AcumuladoTienda
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY G.CodTienda, G.NumGuia, G.FechaSalida;
GO

/*
 IV. OPERADOR PIVOT
*/

-- 31. Mostrar Fecha y columnas CodTienda con TotalEnviado por día
SELECT *
FROM (
    SELECT 
        CAST(G.FechaSalida AS DATE) AS Fecha,
        G.CodTienda,
        D.CantidadEnviada * D.PrecioVenta AS Total
    FROM GUIA_ENVIO G
    JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
) AS Src
PIVOT (
    SUM(Total) FOR CodTienda IN ([1],[2],[3],[4],[5])
) AS P;
GO

-- 32. Mostrar CodArticulo y columnas con cantidades por tienda
SELECT *
FROM (
    SELECT 
        G.CodTienda,
        D.CodArticulo,
        D.CantidadEnviada
    FROM GUIA_ENVIO G
    JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
) AS Src
PIVOT (
    SUM(CantidadEnviada) FOR CodTienda IN ([1],[2],[3],[4],[5])
) AS P;
GO

-- 33. Mostrar NomLinea y tiendas como columnas con suma de PrecioVenta * Cantidad
SELECT *
FROM (
    SELECT 
        L.NomLinea,
        G.CodTienda,
        D.CantidadEnviada * D.PrecioVenta AS Monto
    FROM LINEA L
    JOIN ARTICULO A ON L.CodLinea = A.CodLinea
    JOIN GUIA_DETALLE D ON A.CodArticulo = D.CodArticulo
    JOIN GUIA_ENVIO G ON G.NumGuia = D.NumGuia
) AS Src
PIVOT (
    SUM(Monto) FOR CodTienda IN ([1],[2],[3],[4],[5])
) AS P;
GO

-- 34. Mostrar CodArticulo con columnas para cada Estado
SELECT *
FROM (
    SELECT 
        CodArticulo,
        Estado,
        CantidadSolicitada
    FROM ORDEN_DETALLE
) AS Src
PIVOT (
    SUM(CantidadSolicitada) FOR Estado IN ([Pendiente],[Completado],[Cancelado])
) AS P;
GO

-- 35. Contar artículos por presentación pivotada
SELECT *
FROM (
    SELECT 
        Presentacion,
        CodLinea
    FROM ARTICULO
) AS Src
PIVOT (
    COUNT(CodLinea) FOR Presentacion IN ([Caja],[Unidad],[Paquete],[Set])
) AS P;
GO

-- 36. Generar PIVOT dinámico para todas las tiendas (patrón)//(funcional)
USE QhatuPERU;
GO
DECLARE @Columnas NVARCHAR(MAX), @SQL NVARCHAR(MAX);

-- 1️ Construir la lista dinámica de columnas a partir de CodTienda

SELECT @Columnas = STUFF((
    SELECT ', [' + CAST(CodTienda AS VARCHAR) + ']'
    FROM TIENDA
    GROUP BY CodTienda
    ORDER BY CodTienda
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

-- 2️ Armar la consulta dinámica
SET @SQL = '
SELECT *
FROM (
    SELECT 
        CAST(G.FechaSalida AS DATE) AS Fecha,
        G.CodTienda,
        D.CantidadEnviada
    FROM GUIA_ENVIO G
    JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
) AS SourceTable
PIVOT (
    SUM(CantidadEnviada)
    FOR CodTienda IN (' + @Columnas + ')
) AS PivotTable
ORDER BY Fecha;
';

-- 3️ Ejecutar la consulta generada
PRINT @SQL;  -- opcional, para ver el SQL generado
EXEC sp_executesql @SQL;
GO


-- 37. Mostrar mes y columnas por transportista con totales
SELECT *
FROM (
    SELECT 
        MONTH(G.FechaSalida) AS Mes,
        G.CodTransportista,
        D.CantidadEnviada * D.PrecioVenta AS Total
    FROM GUIA_ENVIO G
    JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
) AS Src
PIVOT (
    SUM(Total) FOR CodTransportista IN ([1],[2],[3],[4],[5])
) AS P;
GO

-- 38. Contar proveedores por rango de variedad de artículos
SELECT Rango, COUNT(*) AS TotalProveedores
FROM (
    SELECT 
        CodProveedor,
        CASE 
            WHEN COUNT(A.CodArticulo) < 10 THEN 'Pocos'
            WHEN COUNT(A.CodArticulo) BETWEEN 10 AND 20 THEN 'Medios'
            ELSE 'Muchos'
        END AS Rango
    FROM ARTICULO A
    GROUP BY CodProveedor
) AS C
GROUP BY Rango;
GO

-- 39. Mostrar CodArticulo y columnas por año con monto total vendido
SELECT *
FROM (
    SELECT 
        D.CodArticulo,
        YEAR(G.FechaSalida) AS Anio,
        D.CantidadEnviada * D.PrecioVenta AS Total
    FROM GUIA_DETALLE D
    JOIN GUIA_ENVIO G ON G.NumGuia = D.NumGuia
) AS Src
PIVOT (
    SUM(Total) FOR Anio IN ([2023],[2024],[2025])
) AS P;
GO

-- 40. Mostrar Mes y columnas por tienda (CASE alternativo)
SELECT 
    MONTH(G.FechaSalida) AS Mes,
    SUM(CASE WHEN G.CodTienda = 1 THEN D.CantidadEnviada ELSE 0 END) AS Tienda1,
    SUM(CASE WHEN G.CodTienda = 2 THEN D.CantidadEnviada ELSE 0 END) AS Tienda2,
    SUM(CASE WHEN G.CodTienda = 3 THEN D.CantidadEnviada ELSE 0 END) AS Tienda3
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY MONTH(G.FechaSalida);
GO

/*
 V. CLÁUSULA HAVING
 */

-- 41. Mostrar CodLinea y CantArticulos donde CantArticulos ≥ 10
SELECT 
    CodLinea,
    COUNT(CodArticulo) AS CantArticulos
FROM ARTICULO
GROUP BY CodLinea
HAVING COUNT(CodArticulo) >= 10;
GO

-- 42. Mostrar CodProveedor y MontoTotal donde MontoTotal > 50000
SELECT 
    CodProveedor,
    SUM(PrecioProveedor * StockActual) AS MontoTotal
FROM ARTICULO
GROUP BY CodProveedor
HAVING SUM(PrecioProveedor * StockActual) > 50000;
GO

-- 43. Mostrar CodTienda y PromedioGuía donde PromedioGuia ≥ 1000
SELECT 
    CodTienda,
    AVG(D.CantidadEnviada * D.PrecioVenta) AS PromedioGuia
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY CodTienda
HAVING AVG(D.CantidadEnviada * D.PrecioVenta) >= 1000;
GO

-- 44. Mostrar CodArticulo y TotalSolicitado ≤ 500
SELECT 
    CodArticulo,
    SUM(CantidadSolicitada) AS TotalSolicitado
FROM ORDEN_DETALLE
GROUP BY CodArticulo
HAVING SUM(CantidadSolicitada) <= 500;
GO

-- 45. Mostrar CodTransportista y CantGuías ≥ 5
SELECT 
    CodTransportista,
    COUNT(NumGuia) AS CantGuias
FROM GUIA_ENVIO
GROUP BY CodTransportista
HAVING COUNT(NumGuia) >= 5;
GO

-- 46. Mostrar líneas donde SUM(StockActual) ≥ SUM(StockMinimo)
SELECT 
    CodLinea,
    SUM(StockActual) AS TotalStock,
    SUM(StockMinimo) AS TotalMinimo
FROM ARTICULO
GROUP BY CodLinea
HAVING SUM(StockActual) >= SUM(StockMinimo);
GO

-- 47. Mostrar proveedores donde MAX(PrecioProveedor) > 100
SELECT 
    CodProveedor,
    MAX(PrecioProveedor) AS MaxPrecio
FROM ARTICULO
GROUP BY CodProveedor
HAVING MAX(PrecioProveedor) > 100;
GO

-- 48. Mostrar tiendas con AVG(CantidadEnviada) < 50 y COUNT(NumGuia) ≥ 10
SELECT 
    CodTienda,
    AVG(D.CantidadEnviada) AS Promedio,
    COUNT(G.NumGuia) AS TotalGuias
FROM GUIA_ENVIO G
JOIN GUIA_DETALLE D ON G.NumGuia = D.NumGuia
GROUP BY CodTienda
HAVING AVG(D.CantidadEnviada) < 50 AND COUNT(G.NumGuia) >= 10;
GO

-- 49. Mostrar CodLínea donde (MAX(Precio) - MIN(Precio)) > 20
SELECT 
    CodLinea,
    (MAX(PrecioProveedor) - MIN(PrecioProveedor)) AS Diferencia
FROM ARTICULO
GROUP BY CodLinea
HAVING (MAX(PrecioProveedor) - MIN(PrecioProveedor)) > 20;
GO

-- 50. Mostrar CodProveedor con COUNT(artículos) donde AVG(StockActual) ≥ 20 y COUNT ≥ 5
SELECT 
    CodProveedor,
    COUNT(CodArticulo) AS TotalArticulos,
    AVG(StockActual) AS PromedioStock
FROM ARTICULO
GROUP BY CodProveedor
HAVING AVG(StockActual) >= 20 AND COUNT(CodArticulo) >= 5;
GO
