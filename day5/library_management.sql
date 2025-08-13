-- Table to store book details
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(13) UNIQUE NOT NULL,  -- ISBN is unique and cannot be null
    title VARCHAR(255) NOT NULL,  -- Title of the book cannot be null
    author VARCHAR(255),
    stock INT DEFAULT 0,  -- Stock count for each book
    available_stock INT DEFAULT 0  -- Available stock for loaning
);

-- Table to store member details
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15) UNIQUE
);

-- Table to store loan details
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    loan_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    status VARCHAR(20) CHECK (status IN ('active', 'returned')) DEFAULT 'active'
);
-- Update available stock after a loan
UPDATE books
SET available_stock = available_stock - 1
WHERE book_id = ? AND available_stock > 0;  -- Make sure stock is available
-- Delete the loan and update the available stock
DELETE FROM loans
WHERE loan_id = ?;

UPDATE books
SET available_stock = available_stock + 1
WHERE book_id = ?;
-- Trigger to check for active loans before inserting a new loan
DELIMITER $$

CREATE TRIGGER check_max_active_loans
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
    DECLARE active_loans INT;

    -- Count the active loans for the member
    SELECT COUNT(*) INTO active_loans
    FROM loans
    WHERE member_id = NEW.member_id
    AND status = 'active';

    -- If the member already has 3 active loans, raise an error
    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot have more than 3 active loans.';
    END IF;
END$$

DELIMITER ;
-- Disable the check by dropping the trigger
DROP TRIGGER IF EXISTS check_max_active_loans;

-- Re-enable the check by recreating the trigger (after your updates)
DELIMITER $$

CREATE TRIGGER check_max_active_loans
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
    DECLARE active_loans INT;

    -- Count the active loans for the member
    SELECT COUNT(*) INTO active_loans
    FROM loans
    WHERE member_id = NEW.member_id
    AND status = 'active';

    -- If the member already has 3 active loans, raise an error
    IF active_loans >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot have more than 3 active loans.';
    END IF;
END$$

DELIMITER ;
-- Start a transaction
DELIMITER $$

CREATE PROCEDURE loan_book(IN member_id INT, IN book_id INT)
BEGIN
    DECLARE available_stock INT;
    
    -- Start the transaction
    START TRANSACTION;

    -- Check if there is enough stock
    SELECT available_stock INTO available_stock FROM books WHERE book_id = book_id;

    -- If stock is available, proceed with the loan
    IF available_stock > 0 THEN
        -- Insert the loan record
        INSERT INTO loans (member_id, book_id, loan_date, status)
        VALUES (member_id, book_id, CURDATE(), 'active');

        -- Update available stock for the book
        UPDATE books
        SET available_stock = available_stock - 1
        WHERE book_id = book_id;

        -- Commit the transaction if everything is okay
        COMMIT;
    ELSE
        -- Rollback if not enough stock
        ROLLBACK;

        -- Raise an error indicating no stock available
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock to loan the book.';
    END IF;

END$$

DELIMITER ;

-- Insert a new book
INSERT INTO books (isbn, title, author, stock, available_stock)
VALUES ('978-3-16-148410-0', 'The Great Gatsby', 'F. Scott Fitzgerald', 10, 10);
DELIMITER $$

CREATE PROCEDURE loan_book(IN member_id INT, IN book_id INT)
BEGIN
    DECLARE available_stock INT;

    -- Start the transaction
    START TRANSACTION;

    -- Check if the book is available
    SELECT available_stock INTO available_stock FROM books WHERE book_id = book_id;

    -- If stock is available, proceed with the loan
    IF available_stock > 0 THEN
        -- Create the loan
        INSERT INTO loans (member_id, book_id, loan_date, status)
        VALUES (member_id, book_id, CURDATE(), 'active');

        -- Update the book stock
        UPDATE books
        SET available_stock = available_stock - 1
        WHERE book_id = book_id;

        -- Commit the transaction if everything is successful
        COMMIT;
    ELSE
        -- Rollback the transaction if there's no stock available
        ROLLBACK;

        -- Raise an error indicating no stock available
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No stock available for loan.';
    END IF;

END$$

DELIMITER ;

-- Return a book and update the stock
DELETE FROM loans WHERE loan_id = ?;  -- Delete the loan record

UPDATE books
SET available_stock = available_stock + 1
WHERE book_id = ?;  -- Update the available stock
