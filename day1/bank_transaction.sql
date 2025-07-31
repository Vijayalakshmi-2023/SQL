CREATE DATABASE bank_db;
USE bank_db;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    address VARCHAR(255)
);
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    location VARCHAR(150)
);
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    branch_id INT,
    account_type VARCHAR(50) NOT NULL,  -- e.g., Checking, Savings
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10),  -- 'credit' or 'debit'
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
INSERT INTO customers (first_name, last_name, email, phone_number, address) VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St, City, Country'),
('Jane', 'Smith', 'jane.smith@example.com', '123-456-7891', '456 Elm St, City, Country'),
('Mary', 'Johnson', 'mary.johnson@example.com', '123-456-7892', '789 Oak St, City, Country');
INSERT INTO branches (branch_name, location) VALUES
('Downtown Branch', '123 Downtown St, City, Country'),
('Uptown Branch', '456 Uptown Ave, City, Country'),
('Suburban Branch', '789 Suburban Rd, City, Country');
INSERT INTO accounts (customer_id, branch_id, account_type, balance) VALUES
(1, 1, 'Checking', 5000.00),
(2, 2, 'Savings', 15000.00),
(3, 3, 'Checking', 2000.00);
INSERT INTO transactions (account_id, transaction_type, amount) VALUES
(1, 'credit', 1000.00),
(1, 'debit', 200.00),
(2, 'credit', 5000.00),
(2, 'debit', 1000.00),
(3, 'debit', 500.00),
(1, 'credit', 1500.00),
(3, 'debit', 300.00);
SELECT t.transaction_id, t.transaction_type, t.amount, t.transaction_date, a.account_type
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id = 1  -- Example for account ID 1 (John Doe)
ORDER BY t.transaction_date DESC;
SELECT a.account_id, a.balance + IFNULL(SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount 
                                                 WHEN t.transaction_type = 'debit' THEN -t.amount 
                                                 END), 0) AS current_balance
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id;
