CREATE DATABASE grocery_store;
USE grocery_store;
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL UNIQUE,
    contact_email VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_level INT DEFAULT 0,
    category_id INT,
    supplier_id INT,
    discontinued BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);
INSERT INTO categories (category_name) VALUES
('Fruits'),
('Vegetables'),
('Dairy'),
('Bakery'),
('Beverages');
INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Fresh Farms', 'contact@freshfarms.com'),
('Green Veggies Co.', 'sales@greenveggies.com'),
('Dairy Delight', 'info@dairydelight.com'),
('Bread Basket', 'support@breadbasket.com'),
('Beverage World', 'service@beverageworld.com');
INSERT INTO products (product_name, price, stock_level, category_id, supplier_id) VALUES
('Apple', 1.50, 100, 1, 1),
('Banana', 0.80, 120, 1, 1),
('Orange', 1.20, 150, 1, 1),
('Spinach', 1.00, 90, 2, 2),
('Carrot', 0.70, 200, 2, 2),
('Broccoli', 1.50, 60, 2, 2),
('Milk', 2.00, 300, 3, 3),
('Cheese', 3.50, 150, 3, 3),
('Butter', 2.20, 180, 3, 3),
('Bread', 1.30, 250, 4, 4),
('Croissant', 2.50, 100, 4, 4),
('Bagel', 1.80, 120, 4, 4),
('Coke', 1.00, 500, 5, 5),
('Pepsi', 0.90, 450, 5, 5),
('Water', 0.50, 600, 5, 5),
('Lemon', 1.00, 80, 1, 1),
('Strawberry', 2.00, 110, 1, 1),
('Yogurt', 1.50, 300, 3, 3),
('Cucumber', 0.60, 130, 2, 2),
('Lettuce', 1.10, 150, 2, 2);
UPDATE products
SET stock_level = stock_level + 50
WHERE product_name = 'Apple';
DELETE FROM products
WHERE discontinued = TRUE;
SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

