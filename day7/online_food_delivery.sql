-- Menu Items Table (Food Items)
CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    supplier_cost DECIMAL(10, 2) NOT NULL,  -- Supplier cost (hidden from customers)
    stock INT NOT NULL
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',  -- Status of the order
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    item_id INT,
    quantity INT NOT NULL,
    item_price DECIMAL(10, 2) NOT NULL,  -- Price at the time of order (locked in)
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- Delivery Queue Table
CREATE TABLE delivery_queue (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    delivery_status VARCHAR(50) DEFAULT 'Queued',
    expected_delivery DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Suppliers Table (only for internal purposes, hidden from customers)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    contact_info TEXT
);

-- Inventory Table
CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    stock INT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);
CREATE VIEW view_menu_items AS
SELECT
    item_id,
    name,
    description,
    price,
    stock
FROM menu_items;
DELIMITER $$

CREATE PROCEDURE place_food_order(
    IN p_customer_id INT,
    IN p_items JSON  -- JSON input containing item_id and quantity
)
BEGIN
    DECLARE v_total_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_item_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_stock INT;

    -- Start a transaction
    START TRANSACTION;

    -- Loop through each item in the JSON input (this assumes a JSON array with item_id and quantity)
    DECLARE cur CURSOR FOR
        SELECT item_id, quantity
        FROM JSON_TABLE(p_items, '$[*]' COLUMNS (
            item_id INT PATH '$.item_id',
            quantity INT PATH '$.quantity'
        )) AS items;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_item_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Get the price of the item and available stock
        SELECT price, stock INTO v_price, v_stock
        FROM menu_items
        WHERE item_id = v_item_id;

        -- Check if there is enough stock
        IF v_stock < v_quantity THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock for item ' + v_item_id;
        END IF;

        -- Deduct stock from inventory
        UPDATE menu_items
        SET stock = stock - v_quantity
        WHERE item_id = v_item_id;

        -- Calculate total amount for the order
        SET v_total_amount = v_total_amount + (v_price * v_quantity);

        -- Insert the item into the order_items table
        INSERT INTO order_items (order_id, item_id, quantity, item_price)
        VALUES (LAST_INSERT_ID(), v_item_id, v_quantity, v_price);
    END LOOP;

    CLOSE cur;

    -- Insert the order record
    INSERT INTO orders (customer_id, total_amount)
    VALUES (p_customer_id, v_total_amount);

    -- Commit the transaction
    COMMIT;

    -- Return the receipt (can return the order details as needed)
    SELECT * FROM orders WHERE order_id = LAST_INSERT_ID();
    
END $$

DELIMITER ;
CALL place_food_order(1, '[{"item_id": 2, "quantity": 3}, {"item_id": 5, "quantity": 2}]');
DELIMITER $$

CREATE FUNCTION get_delivery_eta(p_order_id INT)
RETURNS DATETIME
BEGIN
    DECLARE v_order_date DATETIME;
    DECLARE v_eta DATETIME;

    -- Retrieve the order date
    SELECT order_date INTO v_order_date
    FROM orders
    WHERE order_id = p_order_id;

    -- Estimate the ETA (assuming 30 minutes after order time for simplicity)
    SET v_eta = DATE_ADD(v_order_date, INTERVAL 30 MINUTE);

    RETURN v_eta;
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_order_placed
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    -- Insert the order into the delivery queue
    INSERT INTO delivery_queue (order_id, expected_delivery)
    VALUES (NEW.order_id, get_delivery_eta(NEW.order_id));
END $$

DELIMITER ;
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' IDENTIFIED BY 'admin_password';
-- Grant access to views only (not raw tables)
GRANT SELECT ON view_menu_items TO 'customer_user'@'localhost' IDENTIFIED BY 'customer_password';
