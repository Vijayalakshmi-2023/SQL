CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    total DECIMAL(10,2),
    order_date DATE,
    status VARCHAR(20),
    address VARCHAR(200)
);
SELECT *
FROM orders
WHERE order_date BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE();
SELECT *
FROM orders
WHERE customer_name LIKE 'R%';
SELECT *
FROM orders
WHERE status IS NULL;
SELECT DISTINCT address
FROM orders;
SELECT *
FROM orders
ORDER BY order_date DESC, total DESC;
