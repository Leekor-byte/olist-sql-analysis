-- =============================================================
-- Раздел 6. Влияние опозданий на оценки клиентов
--
-- Вопрос: насколько сильно опоздание снижает оценку?
--
-- Результат:
--   - Доставлен вовремя: avg_score 4.29 (88 163 заказа)
--   - Опоздал: avg_score 2.57 (7 661 заказ)
--   - Разница 1.72 балла — логистика = прямой драйвер NPS
-- =============================================================

SELECT 
    CASE 
        WHEN order_delivered_customer_date <= order_estimated_delivery_date 
        THEN 'Доставлен вовремя'
        ELSE 'Опоздал'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;