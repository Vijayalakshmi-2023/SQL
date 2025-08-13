SELECT 
    u.user_id,
    u.user_name,
    (SELECT AVG(t.amount)
     FROM transactions t
     WHERE t.user_id = u.user_id) AS avg_transaction_value
FROM users u;
SELECT 
    u.city,
    SUM(t.amount) AS total_transactions
FROM transactions t
JOIN users u ON t.user_id = u.user_id
GROUP BY u.city;
SELECT 
    t.transaction_id,
    t.user_id,
    CASE
        WHEN t.transaction_type = 'Credit' THEN 'Credit'
        WHEN t.transaction_type = 'Debit' THEN 'Debit'
        WHEN t.transaction_type = 'Refund' THEN 'Refund'
        ELSE 'Unknown'
    END AS transaction_classification
FROM transactions t;
SELECT user_id, transaction_id, amount, transaction_type, transaction_date, platform
FROM transactions
WHERE platform = 'Platform A'

UNION

SELECT user_id, transaction_id, amount, transaction_type, transaction_date, platform
FROM transactions
WHERE platform = 'Platform B';
SELECT DISTINCT t1.user_id
FROM transactions t1
JOIN transactions t2 ON t1.user_id = t2.user_id
WHERE t1.platform = 'Platform A' 
  AND t2.platform = 'Platform B';

SELECT transaction_id, user_id, amount, transaction_date
FROM transactions
WHERE transaction_date >= CURDATE() - INTERVAL WEEKDAY(CURDATE()) DAY;
SELECT transaction_id, user_id, amount, transaction_date
FROM transactions
WHERE MONTH(transaction_date) = MONTH(CURDATE()) 
AND YEAR(transaction_date) = YEAR(CURDATE());
