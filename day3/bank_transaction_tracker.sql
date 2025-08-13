CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(12,2),
    txn_type VARCHAR(20),  -- 'deposit' or 'withdrawal'
    txn_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
SELECT 
    account_id,
    SUM(CASE WHEN txn_type = 'deposit' THEN amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN amount ELSE 0 END) AS total_withdrawals
FROM transactions
GROUP BY account_id;
SELECT 
    account_id,
    MAX(amount) AS highest_transaction,
    MIN(amount) AS lowest_transaction
FROM transactions
GROUP BY account_id;
SELECT 
    account_id,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN amount ELSE 0 END) AS total_withdrawals
FROM transactions
GROUP BY account_id
HAVING SUM(CASE WHEN txn_type = 'withdrawal' THEN amount ELSE 0 END) > 10000;
SELECT 
    c.customer_id, c.customer_name, c.city, 
    a.account_id, a.account_type
FROM customers c
INNER JOIN accounts a ON c.customer_id = a.customer_id;
SELECT a.account_id, a.customer_id, t.transaction_id
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;
SELECT 
    c1.customer_id AS customer1_id, c1.customer_name AS customer1_name, c1.city,
    c2.customer_id AS customer2_id, c2.customer_name AS customer2_name
FROM customers c1
JOIN customers c2 ON c1.city = c2.city AND c1.customer_id <> c2.customer_id
ORDER BY c1.city;
