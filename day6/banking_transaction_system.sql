-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- Branches Table
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(255) NOT NULL,
    branch_code VARCHAR(10) UNIQUE NOT NULL,
    branch_address VARCHAR(255) NOT NULL
);

-- Accounts Table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_no VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT,
    branch_id INT,
    balance DECIMAL(15, 2) NOT NULL CHECK (balance >= 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    transaction_type ENUM('deposit', 'withdrawal', 'transfer') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    transaction_status ENUM('completed', 'pending', 'failed') NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
-- Index on account_no for quick lookups by account number
CREATE INDEX idx_account_no ON accounts(account_no);

-- Index on transaction_date for efficient filtering by date in transaction history queries
CREATE INDEX idx_transaction_date ON transactions(transaction_date);

-- Index on branch_id for quick searches by branch
CREATE INDEX idx_branch_id ON accounts(branch_id);
EXPLAIN
SELECT balance
FROM accounts
WHERE account_no = 'ABC123';
SELECT t.transaction_id, t.transaction_date, t.transaction_type, t.amount,
       (SELECT SUM(CASE WHEN t2.transaction_type = 'deposit' THEN t2.amount
                        WHEN t2.transaction_type = 'withdrawal' THEN -t2.amount
                        ELSE 0 END)
        FROM transactions t2
        WHERE t2.account_id = t.account_id
        AND t2.transaction_date <= t.transaction_date) AS running_balance
FROM transactions t
WHERE t.account_id = 1
ORDER BY t.transaction_date;
-- Denormalized View for Account and Transaction Summary
CREATE VIEW account_transaction_summary AS
SELECT a.account_no, a.balance, t.transaction_date, t.transaction_type, t.amount
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
ORDER BY t.transaction_date DESC;
SELECT transaction_id, transaction_date, transaction_type, amount
FROM transactions
WHERE account_id = 1
ORDER BY transaction_date DESC
LIMIT 10;
EXPLAIN
SELECT balance
FROM accounts
WHERE account_no = 'ABC123';
SELECT t.transaction_id, t.transaction_date, t.transaction_type, t.amount,
       (SELECT SUM(CASE WHEN t2.transaction_type = 'deposit' THEN t2.amount
                        WHEN t2.transaction_type = 'withdrawal' THEN -t2.amount
                        ELSE 0 END)
        FROM transactions t2
        WHERE t2.account_id = t.account_id
        AND t2.transaction_date <= t.transaction_date) AS running_balance
FROM transactions t
WHERE t.account_id = 1
ORDER BY t.transaction_date;
CREATE VIEW account_transaction_summary AS
SELECT a.account_no, a.balance, t.transaction_date, t.transaction_type, t.amount
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
ORDER BY t.transaction_date DESC;
SELECT transaction_id, transaction_date, transaction_type, amount
FROM transactions
WHERE account_id = 1
ORDER BY transaction_date DESC
LIMIT 10;
