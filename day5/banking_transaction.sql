-- Create the customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Create the accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0), -- Ensure balance is non-negative
    status ENUM('active', 'closed') DEFAULT 'active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create the transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_type ENUM('debit', 'credit') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
-- Insert sample customer data
INSERT INTO customers (name, email) VALUES ('John Doe', 'john.doe@example.com'), ('Jane Smith', 'jane.smith@example.com');

-- Insert sample account data for customers
INSERT INTO accounts (customer_id, balance) VALUES (1, 5000.00), (2, 3000.00);
-- Start a transaction for the money transfer (debit/credit)
DELIMITER $$

CREATE PROCEDURE transfer_money(IN source_account_id INT, IN destination_account_id INT, IN transfer_amount DECIMAL(10,2))
BEGIN
    DECLARE source_balance DECIMAL(10,2);
    DECLARE destination_balance DECIMAL(10,2);

    -- Start the transaction
    START TRANSACTION;

    -- Check balance of source account
    SELECT balance INTO source_balance
    FROM accounts
    WHERE account_id = source_account_id FOR UPDATE;  -- Lock the source account row

    -- If source account does not have enough balance, rollback and signal error
    IF source_balance < transfer_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds for debit.';
    END IF;

    -- Debit from source account
    UPDATE accounts
    SET balance = balance - transfer_amount
    WHERE account_id = source_account_id;

    -- Check if debit was successful
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to debit source account.';
    END IF;

    -- Credit to destination account
    UPDATE accounts
    SET balance = balance + transfer_amount
    WHERE account_id = destination_account_id;

    -- Check if credit was successful
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to credit destination account.';
    END IF;

    -- Commit the transaction if everything is successful
    COMMIT;

END$$

DELIMITER ;

-- Transfer 100 from account 1 to account 2
CALL transfer_money(1, 2, 100.00);
-- Attempt to transfer 1000 from account 1 to account 2, but account 1 only has 500
CALL transfer_money(1, 2, 1000.00);
ERROR 1644 (45000): Insufficient funds for debit.


DELIMITER $$

CREATE PROCEDURE transfer_money(IN source_account_id INT, IN destination_account_id INT, IN transfer_amount DECIMAL(10,2))
BEGIN
    DECLARE source_balance DECIMAL(10,2);
    
    -- Start the transaction
    START TRANSACTION;
    
    -- Lock the source account row to prevent other transactions from modifying it while we process this one
    SELECT balance INTO source_balance
    FROM accounts
    WHERE account_id = source_account_id FOR UPDATE;

    -- Check if source account has sufficient balance
    IF source_balance < transfer_amount THEN
        ROLLBACK;  -- If insufficient funds, roll back the transaction
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds for debit.';
    END IF;

    -- Debit from the source account
    UPDATE accounts
    SET balance = balance - transfer_amount
    WHERE account_id = source_account_id;

    -- Check if debit was successful (i.e., at least 1 row should be updated)
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;  -- If no rows are affected (e.g., account doesn't exist), rollback
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to debit source account.';
    END IF;

    -- Credit to the destination account
    UPDATE accounts
    SET balance = balance + transfer_amount
    WHERE account_id = destination_account_id;

    -- Check if credit was successful
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;  -- If no rows are affected (e.g., destination account doesn't exist), rollback
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to credit destination account.';
    END IF;

    -- Commit the transaction if everything is successful
    COMMIT;
END$$

DELIMITER ;
-- Transfer 100 from account 1 to account 2
CALL transfer_money(1, 2, 100.00);


-- Commit the transaction if everything is successful
COMMIT;
-- Mark account as closed
UPDATE accounts
SET status = 'closed'
WHERE account_id = 1;

-- Delete closed accounts (ensure balance is zero before deleting)
DELETE FROM accounts
WHERE status = 'closed' AND balance = 0;
-- Drop the foreign key constraint between accounts and customers (if necessary)
ALTER TABLE accounts DROP FOREIGN KEY accounts_ibfk_1;
DELIMITER $$

CREATE PROCEDURE transfer_money(IN source_account_id INT, IN destination_account_id INT, IN transfer_amount DECIMAL(10,2))
BEGIN
    DECLARE source_balance DECIMAL(10,2);

    -- Start the transaction
    START TRANSACTION;

    -- Lock the source account row
    SELECT balance INTO source_balance
    FROM accounts
    WHERE account_id = source_account_id FOR UPDATE;  -- Lock the row to prevent other transactions from modifying it

    -- Check if the source account has sufficient funds
    IF source_balance < transfer_amount THEN
        ROLLBACK;  -- Rollback if there are insufficient funds
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds for debit.';
    END IF;

    -- Debit the amount from the source account
    UPDATE accounts
    SET balance = balance - transfer_amount
    WHERE account_id = source_account_id;

    -- Check if the debit was successful
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;  -- Rollback if the update failed
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to debit source account.';
    END IF;

    -- Credit the amount to the destination account
    UPDATE accounts
    SET balance = balance + transfer_amount
    WHERE account_id = destination_account_id;

    -- Check if the credit was successful
    IF ROW_COUNT() = 0 THEN
        ROLLBACK;  -- Rollback if the update failed
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to credit destination account.';
    END IF;

    -- Insert a transaction record for both debit and credit
    INSERT INTO transactions (account_id, transaction_type, amount)
    VALUES (source_account_id, 'debit', transfer_amount),
           (destination_account_id, 'credit', transfer_amount);

    -- Commit the transaction if everything was successful
    COMMIT;
END$$

DELIMITER ;
-- Transfer 200 from account 1 to account 2
CALL transfer_money(1, 2, 200.00);

-- Attempt to transfer 1000 from account 1 to account 2 (assuming account 1 has only 500)
CALL transfer_money(1, 2, 1000.00);

-- Insert a transaction record
INSERT INTO transactions (account_id, transaction_type, amount)
VALUES (1, 'debit', 200), (2, 'credit', 200);

-- Commit the transaction if everything is successful
COMMIT;
-- Session 1 (First transfer)
START TRANSACTION;

-- Debit from account 1
UPDATE accounts
SET balance = balance - 300
WHERE account_id = 1 AND balance >= 300;

-- Credit to account 2
UPDATE accounts
SET balance = balance + 300
WHERE account_id = 2;

-- Commit the transaction
COMMIT;
-- Session 2 (Simultaneous transfer)
START TRANSACTION;

-- Debit from account 1
UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1 AND balance >= 500;

-- Credit to account 3
UPDATE accounts
SET balance = balance + 500
WHERE account_id = 3;

-- Commit the transaction
COMMIT;
-- Lock the accounts table (for strong isolation)
SELECT * FROM accounts WHERE account_id = 1 FOR UPDATE;
