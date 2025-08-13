CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE buyers (
    buyer_id INT PRIMARY KEY,
    buyer_name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    seller_id INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    buyer_id INT,
    product_id INT,
    purchase_date DATE,
    quantity INT,
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
SELECT 
    s.seller_id,
    s.seller_name,
    SUM(pu.quantity * pr.price) AS total_revenue
FROM purchases pu
JOIN products pr ON pu.product_id = pr.product_id
JOIN sellers s ON pr.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_name;
SELECT 
    pr.product_id,
    pr.product_name,
    COUNT(pu.purchase_id) AS purchase_count
FROM purchases pu
JOIN products pr ON pu.product_id = pr.product_id
GROUP BY pr.product_id, pr.product_name
ORDER BY purchase_count DESC;
SELECT 
    s.seller_id,
    s.seller_name,
    SUM(pu.quantity * pr.price) AS total_revenue
FROM purchases pu
JOIN products pr ON pu.product_id = pr.product_id
JOIN sellers s ON pr.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_name
HAVING SUM(pu.quantity * pr.price) > 100000;
SELECT 
    pu.purchase_id,
    pu.purchase_date,
    pr.product_name,
    pr.price,
    s.seller_name
FROM purchases pu
INNER JOIN products pr ON pu.product_id = pr.product_id
INNER JOIN sellers s ON pr.seller_id = s.seller_id;
SELECT 
    s.seller_id,
    s.seller_name,
    pr.product_id,
    pr.product_name
FROM sellers s
LEFT JOIN products pr ON s.seller_id = pr.seller_id;
SELECT 
    s1.seller_id AS seller1_id,
    s1.seller_name AS seller1_name,
    s2.seller_id AS seller2_id,
    s2.seller_name AS seller2_name,
    s1.city
FROM sellers s1
JOIN sellers s2 
  ON s1.city = s2.city AND s1.seller_id <> s2.seller_id
ORDER BY s1.city, s1.seller_id;
