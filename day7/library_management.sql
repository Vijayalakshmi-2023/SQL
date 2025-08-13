-- Books Table (Book Details)
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    genre VARCHAR(50),
    supplier_cost DECIMAL(10, 2) NOT NULL,  -- Supplier cost (hidden from members)
    purchase_price DECIMAL(10, 2) NOT NULL, -- Purchase price (hidden from members)
    stock INT NOT NULL  -- Available stock in the library
);

-- Members Table (Library Members)
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Issues Table (Book Issuing)
CREATE TABLE issues (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    return_date DATETIME,
    status VARCHAR(50) DEFAULT 'issued',  -- Status of the issue (issued, returned)
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Suppliers Table (Supplier Details)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    contact_info TEXT
);

-- Inventory Table (Stock Tracking)
CREATE TABLE inventory (
    book_id INT PRIMARY KEY,
    stock INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
CREATE VIEW view_book_availability AS
SELECT
    book_id,
    title,
    author,
    genre,
    stock  -- Available stock for the book
FROM books;
DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_member_id INT,
    IN p_book_id INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_due_date DATETIME;

    -- Check if the book is available in stock
    SELECT stock INTO v_stock
    FROM books
    WHERE book_id = p_book_id;

    IF v_stock > 0 THEN
        -- Issue the book (insert into issues table)
        INSERT INTO issues (member_id, book_id, return_date)
        VALUES (p_member_id, p_book_id, get_due_date(CURRENT_TIMESTAMP));

        -- Update stock after issuing
        UPDATE books
        SET stock = stock - 1
        WHERE book_id = p_book_id;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is out of stock.';
    END IF;
END $$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION get_due_date(issue_date DATETIME)
RETURNS DATETIME
BEGIN
    -- Set a 14-day return period
    RETURN DATE_ADD(issue_date, INTERVAL 14 DAY);
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_issue
AFTER INSERT ON issues
FOR EACH ROW
BEGIN
    -- Update the book's stock in the inventory table after a book is issued
    UPDATE books
    SET stock = stock - 1
    WHERE book_id = NEW.book_id;
END $$

DELIMITER ;
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' IDENTIFIED BY 'admin_password';
-- Grant access to the view for members
GRANT SELECT ON view_book_availability TO 'member_user'@'localhost' IDENTIFIED BY 'member_password';
