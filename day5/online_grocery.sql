-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Suppliers table
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255)
);
-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE,  -- Unique constraint on product_code
    name VARCHAR(255) NOT NULL,        -- Product name cannot be null
    category_id INT,                  -- Foreign key to categories
    supplier_id INT,                  -- Foreign key to suppliers
    price DECIMAL(10, 2) NOT NULL,    -- Price of the product
    quantity INT CHECK (quantity >= 0), -- Quantity must be >= 0
    expiration_date DATE,             -- Expiration date for products
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Stock logs table
CREATE TABLE stock_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity_change INT,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Insert a new product with valid category and supplier
INSERT INTO products (product_code, name, category_id, supplier_id, price, quantity, expiration_date)
VALUES ('P001', 'Apple', 1, 1, 1.99, 100, '2025-12-31');
-- Update product price and quantity with validation
UPDATE products
SET price = ?, quantity = ?
WHERE product_code = ? AND quantity >= 0;
-- Delete expired products (products where expiration date has passed)
DELETE FROM products
WHERE expiration_date < CURDATE();
-- Drop UNIQUE constraint on product_code
ALTER TABLE products DROP INDEX product_code;
-- Recreate UNIQUE constraint on product_code
ALTER TABLE products ADD UNIQUE (product_code);
-- Start a transaction
START TRANSACTION;

-- Set a SAVEPOINT before the bulk update
SAVEPOINT before_bulk_update;

-- Bulk update price for products
UPDATE products
SET price = price * 1.10  -- Example: increase all product prices by 10%
WHERE category_id = 1;

-- If anything fails, roll back to the savepoint
-- (you would handle failure detection in application code)
-- ROLLBACK TO SAVEPOINT before_bulk_update; -- Uncomment this in case of failure

-- Commit the transaction if everything is successful
COMMIT;
-- Start a transaction
START TRANSACTION;

-- Update product inventory (quantity)
UPDATE products
SET quantity = quantity + ?
WHERE product_code = ?;

-- Insert a stock log entry
INSERT INTO stock_logs (product_id, quantity_change)
VALUES ((SELECT product_id FROM products WHERE product_code = ?), ?);

-- Commit the transaction if everything is successful
COMMIT;
-- Insert new categories and suppliers
INSERT INTO categories (name) VALUES ('Fruits'), ('Vegetables');
INSERT INTO suppliers (name, contact_info) VALUES ('Supplier A', '123-456-7890'), ('Supplier B', '987-654-3210');

-- Insert products with foreign keys
INSERT INTO products (product_code, name, category_id, supplier_id, price, quantity, expiration_date)
VALUES ('P001', 'Apple', 1, 1, 1.99, 100, '2025-12-31'),
       ('P002', 'Banana', 1, 2, 0.99, 150, '2025-11-30');

-- Update price and quantity
UPDATE products
SET price = 2.49, quantity = 120
WHERE product_code = 'P001';

-- Delete expired products
DELETE FROM products
WHERE expiration_date < CURDATE();

-- Drop and recreate UNIQUE constraint on product_code
ALTER TABLE products DROP INDEX product_code;
ALTER TABLE products ADD UNIQUE (product_code);

-- Use SAVEPOINT for bulk price updates
START TRANSACTION;
SAVEPOINT before_bulk_update;
UPDATE products
SET price = price * 1.10
WHERE category_id = 1;
COMMIT;
