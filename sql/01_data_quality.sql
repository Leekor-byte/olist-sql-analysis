-- =============================================================
-- Раздел 1. Качество данных: проверка дубликатов
--
-- Вопрос: есть ли дубликаты в ключевых таблицах?
--
-- Результат:
--   - order_reviews: 551 дубликатов по order_id (часть заказов
--     имеет несколько отзывов — особенность датасета)
--   - order_payments: 4446 повторов по order_id — норма,
--     мультиоплаты (voucher + credit_card и т.п.)
--   - Дубликаты НЕ удаляем — отражают бизнес-логику
-- =============================================================

SELECT 'order_reviews' AS table_name,
       COUNT(*) AS total_rows,
       COUNT(DISTINCT review_id) AS distinct_review_id,
       COUNT(DISTINCT order_id) AS distinct_order_id,
       COUNT(*) - COUNT(DISTINCT review_id) AS dup_review_id,
       COUNT(*) - COUNT(DISTINCT order_id) AS dup_order_id
FROM order_reviews

UNION ALL

SELECT 'order_payments',
       COUNT(*),
       COUNT(DISTINCT order_id || '-' || payment_sequential),
       COUNT(DISTINCT order_id),
       COUNT(*) - COUNT(DISTINCT order_id || '-' || payment_sequential),
       COUNT(*) - COUNT(DISTINCT order_id)
FROM order_payments;