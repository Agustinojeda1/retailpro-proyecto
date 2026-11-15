-- Motor utilizado: SQL Server (SSMS)
-- Pre-entrega 4: Consultas SQL de negocio (RetailPro)
-- Base de datos: Ventas_Tech_DB (tabla ventas)

USE Ventas_Tech_DB;

-- === CONSULTA 1: Resumen ejecutivo mensual ===
-- Total facturado, cantidad de pedidos y ticket promedio por mes
SELECT
    MONTH(fecha_venta)                  AS mes,
    SUM(cantidad * precio_unitario)     AS total_facturado,
    COUNT(*)                            AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)     AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- === CONSULTA 2: Ranking de productos (Top 5 por facturación) ===
SELECT TOP 5
    id_producto,
    SUM(cantidad)                       AS unidades_vendidas,
    SUM(cantidad * precio_unitario)     AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- === CONSULTA 3: Clientes recurrentes (más de un pedido) ===
SELECT
    id_cliente,
    COUNT(*)                            AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- === CONSULTA 4: Productos por encima / por debajo del promedio ===
-- El promedio es el de los totales por producto (no el de las filas de ventas)
WITH total_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM total_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS posicion_vs_promedio
FROM total_por_producto
ORDER BY total_facturado DESC;

-- === HALLAZGOS ===
-- 1. El producto 1 concentra cerca del 56% de la facturación (3600 de 6444),
--    y junto con el producto 3 suman casi el 77%: el negocio depende de dos productos.
-- 2. El producto 2 es el que más unidades vende (13) pero aporta solo ~5.6% de la
--    facturación (364), porque su precio unitario es muy bajo.
-- 3. Los 5 clientes compraron exactamente 2 veces cada uno, por lo que todos son
--    recurrentes; el cliente 1 es el que más gastó (2640, cerca del 41% del total).
