-- =============================================================
-- Раздел 7. Платёжное поведение
--
-- Вопрос: какие способы оплаты доминируют?
--
-- Результат:
--   - credit_card: 76 795 платежей, 12.54 млн BRL (81% выручки),
--     средняя рассрочка 3.5 месяца
--   - boleto: 19 784 платежа, 2.87 млн BRL (~19%)
--   - voucher + debit_card: суммарно ~3%
-- =============================================================

SELECT 
    payment_type,
    COUNT(*) AS payments_count,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;