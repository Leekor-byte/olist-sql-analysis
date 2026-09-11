-- =============================================================
-- Раздел 9. RFM-сегментация клиентов
--
-- Вопрос: какие сегменты клиентов приоритетны для возврата?
--
-- Результат (сегмент | клиентов | avg_monetary | avg_recency):
--   - Ушедшие         | 23 737 | 47.7  | 412
--   - В зоне риска    | 22 943 | 236.7 | 412  ← приоритет №1
--   - Лояльные        | 11 899 | 229.7 | 214
--   - Чемпионы        | 11 836 | 239.7 | 107
--   - Новички         | 11 503 | 47.4  | 104
--
-- Важно: используем customer_unique_id — реального покупателя,
-- а не customer_id (уникален для каждого заказа).
-- =============================================================

WITH customer_metrics AS (
    SELECT 
        c.customer_unique_id,
        CAST(julianday((SELECT MAX(order_purchase_timestamp) FROM orders)) 
             - julianday(MAX(o.order_purchase_timestamp)) AS INTEGER) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency) AS f_score,
        NTILE(4) OVER (ORDER BY monetary) AS m_score
    FROM customer_metrics
)
SELECT 
    *,
    r_score * 100 + f_score * 10 + m_score AS rfm_cell,
    CASE
        WHEN r_score = 4 AND f_score >= 3  THEN 'Чемпионы'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Лояльные'
        WHEN r_score = 4 AND f_score <= 2  THEN 'Новички'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'В зоне риска'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Ушедшие'
        ELSE 'Потенциально лояльные'
    END AS segment
FROM rfm_scores;