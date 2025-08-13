CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(15)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    discount_rate DECIMAL(5, 2),  -- Discount as a percentage
    total_amount DECIMAL(10, 2),  -- Final total after applying discount
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE VIEW view_order_summary AS
SELECT 
    o.order_id, 
    c.customer_name,
    -- Calculating total amount after discount (but hiding discount logic)
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
DELIMITER $$

CREATE PROCEDURE place_order(
    IN customer_id INT,
    IN order_date TIMESTAMP,
    IN discount_rate DECIMAL(5, 2),
    IN items JSON -- Assuming the items are passed as a JSON array containing product_id, quantity, and unit_price
)
BEGIN
    -- Insert order into orders table
    DECLARE new_order_id INT;

    INSERT INTO orders (customer_id, order_date, discount_rate)
    VALUES (customer_id, order_date, discount_rate);

    -- Get the last inserted order_id
    SET new_order_id = LAST_INSERT_ID();

    -- Loop through the items JSON and insert each item into order_items table
    DECLARE i INT DEFAULT 0;
    DECLARE item_count INT;
    SET item_count = JSON_LENGTH(items);

    WHILE i < item_count DO
        DECLARE product_id INT;
        DECLARE quantity INT;
        DECLARE unit_price DECIMAL(10, 2);

        SET product_id = JSON_UNQUOTE(JSON_EXTRACT(items, CONCAT('$[', i, '].product_id')));
        SET quantity = JSON_UNQUOTE(JSON_EXTRACT(items, CONCAT('$[', i, '].quantity')));
        SET unit_price = JSON_UNQUOTE(JSON_EXTRACT(items, CONCAT('$[', i, '].unit_price')));

        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (new_order_id, product_id, quantity, unit_price);

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION get_order_total(order_id INT) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_cost DECIMAL(10, 2);
    DECLARE discount_rate DECIMAL(5, 2);
    
    -- Get the discount rate for the order
    SELECT discount_rate INTO discount_rate FROM orders WHERE order_id = order_id;

    -- Calculate the total cost from the order items
    SELECT SUM(oi.quantity * oi.unit_price) INTO total_cost
    FROM order_items oi
    WHERE oi.order_id = order_id;

    -- Apply discount to the total cost
    SET total_cost = total_cost - (total_cost * (discount_rate / 100));

    RETURN total_cost;
END$$

DELIMITER ;
CREATE TABLE order_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    customer_id INT,
    action VARCHAR(50),
    audit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
DELIMITER $$

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (order_id, customer_id, action)
    VALUES (NEW.order_id, NEW.customer_id, 'Order Placed');
END$$

DELIMITER ;
CREATE VIEW view_read_only_customer_info AS
SELECT customer_id, customer_name
FROM customers;
