-- =============================================================
-- Раздел 3. Динамика выручки
--
-- Вопрос: как менялась выручка Olist по месяцам?
--
-- Результат:
--   - Рост с 127 тыс. BRL (янв 2017) до ~1.1 млн BRL/мес в 2018
--   - Пик ноябрь 2017 (Black Friday): 1.15 млн BRL
--   - Плато с марта 2018
-- =============================================================

SELECT 
    substr(o.order_purchase_timestamp, 1, 7) AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;