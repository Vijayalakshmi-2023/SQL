-- Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) NOT NULL UNIQUE
);

-- Suppliers Table
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255)
);

-- Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    supplier_id INT,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Inventory Table
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE NOT NULL,
    customer_id INT,  -- Assuming customer_id is already in another table
    order_status VARCHAR(50)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Denormalized Sales Summary Table
CREATE TABLE sales_summary (
    product_id INT PRIMARY KEY,
    total_sales_quantity INT DEFAULT 0,
    total_revenue DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Update Sales Summary Table (e.g., monthly)
INSERT INTO sales_summary (product_id, total_sales_quantity, total_revenue)
SELECT oi.product_id, SUM(oi.quantity), SUM(oi.quantity * oi.unit_price)
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY oi.product_id
ON DUPLICATE KEY UPDATE
    total_sales_quantity = VALUES(total_sales_quantity),
    total_revenue = VALUES(total_revenue);
-- Create Index on product_name for faster searches by product name
CREATE INDEX idx_product_name ON products(product_name);

-- Create Index on category_id for faster filtering by category
CREATE INDEX idx_category_id ON products(category_id);

-- Create Index on supplier_id for faster filtering by supplier
CREATE INDEX idx_supplier_id ON products(supplier_id);
EXPLAIN SELECT p.product_id, p.product_name, p.price, c.category_name, s.supplier_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.product_name LIKE '%Laptop%' 
AND c.category_name = 'Electronics'
AND s.supplier_name = 'ABC Supplier';
SELECT p.product_name, ss.total_sales_quantity, ss.total_revenue
FROM products p
JOIN sales_summary ss ON p.product_id = ss.product_id
WHERE ss.total_sales_quantity = (
    SELECT MAX(total_sales_quantity)
    FROM sales_summary
);
-- Query without indexing
SELECT p.product_id, p.product_name, p.price, c.category_name, s.supplier_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.product_name LIKE '%Laptop%';
-- Create indexes first (if not already created)
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_category_id ON products(category_id);
CREATE INDEX idx_supplier_id ON products(supplier_id);

-- Query with indexing
SELECT p.product_id, p.product_name, p.price, c.category_name, s.supplier_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.product_name LIKE '%Laptop%';
SELECT p.product_name, SUM(oi.quantity) AS total_quantity_ordered
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_ordered DESC
LIMIT 10;
