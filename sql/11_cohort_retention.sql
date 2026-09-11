-- =============================================================
-- Раздел 10. Когортный анализ: Retention
--
-- Вопрос: возвращаются ли клиенты после первой покупки?
--
-- Результат:
--   - Retention на 1-й месяц: 0.2–0.7%
--   - Retention на 3-й месяц: 0.1–0.4%
--   - Retention на 6-й месяц: 0.1–0.4%
--   - Вывод: Olist — маркетплейс разовых покупок. Классические
--     retention-кампании малоэффективны, нужны категорийные триггеры.
--
-- Важно: используем customer_unique_id для корректной идентификации.
-- =============================================================

WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(substr(o.order_purchase_timestamp, 1, 7)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS size
    FROM first_purchase
    GROUP BY cohort_month
),
activity AS (
    SELECT 
        f.cohort_month,
        (CAST(substr(o.order_purchase_timestamp,1,4) AS INTEGER) 
            - CAST(substr(f.cohort_month,1,4) AS INTEGER)) * 12
        + (CAST(substr(o.order_purchase_timestamp,6,2) AS INTEGER) 
            - CAST(substr(f.cohort_month,6,2) AS INTEGER)) AS month_number,
        COUNT(DISTINCT c.customer_unique_id) AS active_customers
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_purchase f ON c.customer_unique_id = f.customer_unique_id
    WHERE o.order_status = 'delivered'
    GROUP BY f.cohort_month, month_number
)
SELECT 
    cs.cohort_month,
    cs.size AS cohort_size,
    ROUND(100.0 * MAX(CASE WHEN a.month_number=0 THEN a.active_customers END)/cs.size, 1) AS m0,
    ROUND(100.0 * MAX(CASE WHEN a.month_number=1 THEN a.active_customers END)/cs.size, 1) AS m1,
    ROUND(100.0 * MAX(CASE WHEN a.month_number=3 THEN a.active_customers END)/cs.size, 1) AS m3,
    ROUND(100.0 * MAX(CASE WHEN a.month_number=6 THEN a.active_customers END)/cs.size, 1) AS m6
FROM cohort_size cs
LEFT JOIN activity a USING (cohort_month)
GROUP BY cs.cohort_month, cs.size
ORDER BY cs.cohort_month;