-- Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE, 
    phone VARCHAR(20) UNIQUE, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Menu Items Table
CREATE TABLE menu_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,  -- Price of the menu item
    available_quantity INT CHECK (available_quantity >= 0),  -- Quantity available
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,  -- Foreign Key to customers
    item_id INT,      -- Foreign Key to menu_items
    order_quantity INT CHECK (order_quantity <= 10),  -- Ensure order quantity is <= 10
    table_number INT,  -- Table number where the order was placed
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of the order
    status VARCHAR(20) DEFAULT 'pending',  -- Status of the order (pending, completed, etc.)
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id) ON DELETE CASCADE
);

-- Bills Table
CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,  -- Foreign Key to orders
    total_amount DECIMAL(10, 2) NOT NULL,  -- Total bill amount
    payment_status VARCHAR(20) DEFAULT 'unpaid',  -- Payment status (paid, unpaid)
    bill_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the bill was created
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
-- Drop the NOT NULL constraint from table_number
ALTER TABLE orders MODIFY COLUMN table_number INT NULL;

-- Reapply the NOT NULL constraint to table_number
ALTER TABLE orders MODIFY COLUMN table_number INT NOT NULL;
START TRANSACTION;

-- Insert a new order
INSERT INTO orders (customer_id, item_id, order_quantity, table_number)
VALUES (1, 2, 3, 5);  -- Customer 1 orders 3 of item 2 for table 5

-- Update the menu item's available quantity after the order
UPDATE menu_items
SET available_quantity = available_quantity - 3
WHERE item_id = 2 AND available_quantity >= 3;


-- Insert a bill for the order (calculate the total amount)
INSERT INTO bills (order_id, total_amount)
VALUES (LAST_INSERT_ID(), 3 * (SELECT price FROM menu_items WHERE item_id = 2));

-- Commit the transaction if everything is successful
COMMIT;
DELETE FROM orders
WHERE status = 'pending' AND order_time < NOW() - INTERVAL 30 MINUTE;
START TRANSACTION;

-- Assume customer 1 orders 2 of item 1 for table 4
SET @customer_id = 1;
SET @item_id = 1;
SET @order_quantity = 2;
SET @table_number = 4;

-- Check if the requested quantity is available
SELECT available_quantity INTO @available_quantity
FROM menu_items
WHERE item_id = @item_id;



-- Insert the order
INSERT INTO orders (customer_id, item_id, order_quantity, table_number)
VALUES (@customer_id, @item_id, @order_quantity, @table_number);

-- Update item availability
UPDATE menu_items
SET available_quantity = available_quantity - @order_quantity
WHERE item_id = @item_id;

-- Insert the bill for the order
INSERT INTO bills (order_id, total_amount)
VALUES (LAST_INSERT_ID(), @order_quantity * (SELECT price FROM menu_items WHERE item_id = @item_id));

-- Commit if everything goes fine
COMMIT;
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
       ('Bob', 'Smith', 'bob.smith@example.com', '987-654-3210');
INSERT INTO menu_items (item_name, price, available_quantity)
VALUES ('Burger', 10.99, 50),
       ('Pizza', 15.99, 30),
       ('Pasta', 12.99, 20);
-- Example transaction for inserting an order and bill
START TRANSACTION;

-- Customer 1 orders 2 Burgers (item_id = 1) for table 3
INSERT INTO orders (customer_id, item_id, order_quantity, table_number)
VALUES (1, 1, 2, 3);

-- Update the available quantity of the item (Burger)
UPDATE menu_items
SET available_quantity = available_quantity - 2
WHERE item_id = 1 AND available_quantity >= 2;

-- Insert the bill for the order (calculate total)
INSERT INTO bills (order_id, total_amount)
VALUES (LAST_INSERT_ID(), 2 * (SELECT price FROM menu_items WHERE item_id = 1));

-- Commit if everything is successful
COMMIT;
-- Create an event to delete unpaid orders older than 30 minutes
CREATE EVENT delete_timeout_orders
ON SCHEDULE EVERY 1 MINUTE
DO
  DELETE FROM orders
  WHERE status = 'pending' AND order_time < NOW() - INTERVAL 30 MINUTE;
