-- Motor utilizado: SQL Server (SSMS)
-- Pre-entrega 5: Consultas con JOINs (RetailPro)
-- Base de datos: Ventas_Tech_DB (categorias, clientes, productos, ventas)

USE Ventas_Tech_DB;

-- === CONSULTA 1: Vista base del proyecto (INNER JOIN) ===
-- Propósito: una sola fila por venta con cliente, ciudad, producto y categoría,
-- como fuente de datos principal para Power BI.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                            AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario      AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: las 10 ventas cruzan sin perder filas y suman 6444. La categoría
-- Computación (laptops y monitores) genera 4950, cerca del 77% de la facturación.

-- === CONSULTA 2: Clientes sin ventas (LEFT JOIN) ===
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: aparecen 0 clientes, los 5 registrados compraron al menos una vez.
-- Para CRM no hay clientes inactivos que reactivar con los datos actuales.

-- === CONSULTA 3: Productos sin ventas (LEFT JOIN) ===
-- Propósito: identificar artículos del catálogo sin movimiento, para el área de producto.
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v      ON p.id_producto  = v.id_producto
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;
-- Hallazgo: aparecen 0 productos, los 6 del catálogo tuvieron al menos una venta.
-- Producto no tiene artículos sin rotación que revisar por ahora.

-- === CONSULTA 4: Consolidado por período (UNION ALL) ===
-- Propósito: comparar la facturación de dos tramos de marzo de 2024. La columna
-- canal no existe en las tablas: se crea como valor literal en cada SELECT.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Hasta el 10 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Desde el 11 de marzo' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
) AS consolidado
GROUP BY canal;
-- Hallazgo: el tramo hasta el 10 de marzo facturó 3620 y el posterior 2824;
-- la primera parte del mes vendió un 28% más (el total de ambos es 6444).
