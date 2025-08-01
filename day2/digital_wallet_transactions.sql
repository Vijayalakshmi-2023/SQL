CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    txn_type VARCHAR(50),
    txn_date DATETIME,
    status VARCHAR(20)
);
SELECT user_id, amount, txn_type
FROM transactions
WHERE amount BETWEEN 100 AND 1000;
SELECT *
FROM transactions
WHERE txn_type LIKE '%recharge%';
SELECT *
FROM transactions
WHERE status IS NULL;
SELECT *
FROM transactions
ORDER BY txn_date DESC;
