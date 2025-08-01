CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT,
    supplier VARCHAR(100),
    description TEXT
);
SELECT name, category, price
FROM products
WHERE price BETWEEN 100 AND 1000;
SELECT *
FROM products
WHERE name LIKE '%phone%';
SELECT *
FROM products
WHERE description IS NULL;
SELECT DISTINCT supplier
FROM products;
SELECT *
FROM products
WHERE stock = 0 OR price > 5000;
SELECT *
FROM products
ORDER BY category ASC, price DESC;
