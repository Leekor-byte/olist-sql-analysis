-- =============================================================
-- Раздел 5. Логистика и сроки доставки
--
-- Вопрос 1: какие средние сроки доставки и % опозданий?
-- Вопрос 2: как распределены сроки (медиана, p90, p95)?
--
-- Результат:
--   - Среднее 12.6 дней, медиана 10, p90 23, максимум 210
--   - 8.11% заказов опаздывают относительно estimate
--   - Для SLA-ориентированной логистики цель p90 ≤ 21 день
-- =============================================================

-- Запрос 1: средние сроки и % опозданий
SELECT 
    ROUND(AVG(julianday(order_delivered_customer_date) 
            - julianday(order_purchase_timestamp)), 1) AS avg_delivery_days,
    ROUND(AVG(julianday(order_estimated_delivery_date) 
            - julianday(order_delivered_customer_date)), 1) AS avg_days_earlier_than_estimate,
    ROUND(SUM(CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date 
        THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS pct_late
FROM orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL;


-- Запрос 2: медиана и перцентили распределения сроков
WITH delivery_days AS (
    SELECT 
        order_id,
        julianday(order_delivered_customer_date) 
            - julianday(order_purchase_timestamp) AS days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
),
ranked AS (
    SELECT 
        days,
        ROW_NUMBER() OVER (ORDER BY days) AS rn,
        COUNT(*) OVER () AS total
    FROM delivery_days
)
SELECT
    ROUND(AVG(days), 2) AS mean_days,
    ROUND(MAX(CASE WHEN rn = CAST(total * 0.50 AS INTEGER) THEN days END), 1) AS p50_median,
    ROUND(MAX(CASE WHEN rn = CAST(total * 0.75 AS INTEGER) THEN days END), 1) AS p75,
    ROUND(MAX(CASE WHEN rn = CAST(total * 0.90 AS INTEGER) THEN days END), 1) AS p90,
    ROUND(MAX(CASE WHEN rn = CAST(total * 0.95 AS INTEGER) THEN days END), 1) AS p95,
    ROUND(MIN(days), 1) AS min_days,
    ROUND(MAX(days), 1) AS max_days
FROM ranked;