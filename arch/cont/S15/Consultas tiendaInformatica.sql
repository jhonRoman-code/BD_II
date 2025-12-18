USE tiendaInformatica;
GO

-- 1
SELECT nombre FROM producto;
GO

-- 2
SELECT nombre, precio FROM producto;
GO

-- 3
SELECT * FROM producto;
GO

-- 4
SELECT nombre, precio, precio * 1.10 AS dolares FROM producto;
GO

-- 5
SELECT nombre AS [nombre de producto],
       precio AS euros,
       precio * 1.10 AS dolares
FROM producto;
GO

-- 6
SELECT UPPER(nombre) AS nombre, precio FROM producto;
GO

-- 7
SELECT LOWER(nombre) AS nombre, precio FROM producto;
GO

-- 8
SELECT nombre, UPPER(LEFT(nombre, 2)) AS iniciales FROM fabricante;
GO

-- 9
SELECT nombre, ROUND(precio, 0) AS precio_redondeado FROM producto;
GO

-- 10
SELECT nombre, CAST(precio AS INT) AS precio_truncado FROM producto;
GO

-- 11
SELECT id_fabricante FROM producto;
GO

-- 12
SELECT DISTINCT id_fabricante FROM producto;
GO

-- 13
SELECT nombre FROM fabricante ORDER BY nombre ASC;
GO

-- 14
SELECT nombre FROM fabricante ORDER BY nombre DESC;
GO

-- 15
SELECT nombre, precio
FROM producto
ORDER BY nombre ASC, precio DESC;
GO

-- 16
SELECT TOP 5 * FROM fabricante;
GO

-- 17
SELECT *
FROM fabricante
ORDER BY id
OFFSET 3 ROWS FETCH NEXT 2 ROWS ONLY;
GO

-- 18
SELECT TOP 1 nombre, precio
FROM producto
ORDER BY precio ASC;
GO

-- 19
SELECT TOP 1 nombre, precio
FROM producto
ORDER BY precio DESC;
GO

-- 20
SELECT nombre FROM producto WHERE id_fabricante = 2;
GO

-- 21
SELECT nombre FROM producto WHERE precio <= 120;
GO

-- 22
SELECT nombre FROM producto WHERE precio >= 400;
GO

-- 23
SELECT nombre FROM producto WHERE precio < 400;
GO

-- 24
SELECT * FROM producto
WHERE precio >= 80 AND precio <= 300;
GO

-- 25
SELECT * FROM producto
WHERE precio BETWEEN 60 AND 200;
GO

-- 26
SELECT * FROM producto
WHERE precio > 200 AND id_fabricante = 6;
GO

-- 27
SELECT * FROM producto
WHERE id_fabricante = 1
   OR id_fabricante = 3
   OR id_fabricante = 5;
GO

-- 28
SELECT * FROM producto
WHERE id_fabricante IN (1, 3, 5);
GO

-- 29
SELECT nombre, precio * 100 AS centimos FROM producto;
GO

-- 30
SELECT nombre FROM fabricante WHERE nombre LIKE 'S%';
GO

-- 31
SELECT nombre FROM fabricante WHERE nombre LIKE '%e';
GO

-- 32
SELECT nombre FROM fabricante WHERE nombre LIKE '%w%';
GO

-- 33
SELECT nombre FROM fabricante WHERE LEN(nombre) = 4;
GO

-- 34
SELECT nombre FROM producto WHERE nombre LIKE '%Portátil%';
GO

-- 35
SELECT nombre
FROM producto
WHERE nombre LIKE '%Monitor%'
AND precio < 215;
GO

-- 36
SELECT nombre, precio
FROM producto
WHERE precio >= 180
ORDER BY precio DESC, nombre ASC;
GO
