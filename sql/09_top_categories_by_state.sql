-- =============================================================
-- Раздел 8. География продаж: топ-3 категории по штатам
--
-- Вопрос: какие категории лидируют в каждом штате?
--
-- Результат:
--   - Крупные штаты (SP, RJ, MG, BA, CE, DF): health_beauty,
--     watches_gifts
--   - Малые штаты (AC, AP, AM): sports_leisure, computers_accessories
--   - Ассортиментная стратегия должна различаться по регионам
-- =============================================================

WITH state_category_revenue AS (
    SELECT 
        c.customer_state,
        ct.product_category_name_english AS category,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN category_translation ct ON p.product_category_name = ct.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state, category
),
ranked AS (
    SELECT 
        customer_state,
        category,
        revenue,
        RANK() OVER (PARTITION BY customer_state ORDER BY revenue DESC) AS rank_in_state
    FROM state_category_revenue
)
SELECT 
    customer_state,
    category,
    ROUND(revenue, 2) AS revenue,
    rank_in_state
FROM ranked
WHERE rank_in_state <= 3
ORDER BY customer_state, rank_in_state;