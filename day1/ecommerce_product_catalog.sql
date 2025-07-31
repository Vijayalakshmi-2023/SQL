CREATE DATABASE ecommerce_db;
USE ecommerce_db;
CREATE TABLE brands (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    brand_id INT,
    category_id INT,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO brands (brand_name) VALUES
('Nike'),
('Adidas'),
('Apple'),
('Samsung'),
('Sony');
INSERT INTO categories (category_name) VALUES
('Footwear'),
('Electronics'),
('Accessories'),
('Apparel');
INSERT INTO users (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice.johnson@ecommerce.com'),
('Bob', 'Smith', 'bob.smith@ecommerce.com'),
('Charlie', 'Davis', 'charlie.davis@ecommerce.com'),
('David', 'Martinez', 'david.martinez@ecommerce.com'),
('Emily', 'Garcia', 'emily.garcia@ecommerce.com');
INSERT INTO products (product_name, price, description, brand_id, category_id) VALUES
('Nike Air Max', 120.00, 'Comfortable and stylish running shoes.', 1, 1),
('Adidas UltraBoost', 150.00, 'High-performance running shoes with Boost technology.', 2, 1),
('Apple iPhone 13', 799.99, 'Latest iPhone model with A15 chip.', 3, 2),
('Samsung Galaxy S21', 999.99, 'Flagship phone with Exynos 2100 processor.', 4, 2),
('Sony WH-1000XM4', 350.00, 'Wireless noise-cancelling over-ear headphones.', 5, 3),
('Nike Dri-FIT T-Shirt', 30.00, 'Breathable workout T-shirt with Dri-FIT technology.', 1, 4),
('Adidas Performance Shorts', 25.00, 'Lightweight, moisture-wicking shorts for exercise.', 2, 4),
('Apple AirPods Pro', 249.00, 'True wireless noise-cancelling earbuds.', 3, 3),
('Samsung Galaxy Watch 4', 250.00, 'Smartwatch with fitness tracking features.', 4, 3),
('Nike Running Socks', 15.00, 'Comfortable socks for long-distance runners.', 1, 4);
INSERT INTO favorites (user_id, product_id) VALUES
(1, 1),  -- Alice favorites Nike Air Max
(2, 3),  -- Bob favorites Apple iPhone 13
(3, 2),  -- Charlie favorites Adidas UltraBoost
(4, 4),  -- David favorites Samsung Galaxy S21
(5, 5),  -- Emily favorites Sony WH-1000XM4
(1, 6),  -- Alice favorites Nike Dri-FIT T-Shirt
(2, 7),  -- Bob favorites Adidas Performance Shorts
(3, 8),  -- Charlie favorites Apple AirPods Pro
(4, 9),  -- David favorites Samsung Galaxy Watch 4
(5, 10); -- Emily favorites Nike Running Socks
SELECT p.product_name, p.price, p.description, b.brand_name, c.category_name
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
WHERE c.category_name = 'Footwear';
SELECT p.product_name, p.price, p.description, c.category_name
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
WHERE b.brand_name = 'Nike';
SELECT p.product_name, b.brand_name, COUNT(f.favorite_id) AS favorite_count
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
LEFT JOIN favorites f ON p.product_id = f.product_id
GROUP BY p.product_id
ORDER BY favorite_count DESC;
