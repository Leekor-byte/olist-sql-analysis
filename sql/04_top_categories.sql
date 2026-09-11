-- =============================================================
-- Раздел 4. Топ-10 категорий по выручке
--
-- Вопрос: какие категории дают основную выручку?
--
-- Результат:
--   - Лидеры: health_beauty (1.26 млн BRL), watches_gifts (1.21 млн)
--   - bed_bath_table имеет больше заказов, но меньше выручки —
--     средний чек ниже в 1.8 раза
--   - Топ-10 формируют ~60% выручки
-- =============================================================

SELECT 
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;