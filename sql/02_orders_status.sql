-- =============================================================
-- Раздел 2. Статусы заказов и завершённость
--
-- Вопрос: как распределены статусы заказов и есть ли потери?
--
-- Результат:
--   - delivered: 97.02%
--   - canceled + unavailable = 1.24% — прямые потери
--   - Для анализа выручки далее фильтруем только delivered
-- =============================================================

SELECT 
    order_status,
    COUNT(*) AS orders_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders_count DESC;