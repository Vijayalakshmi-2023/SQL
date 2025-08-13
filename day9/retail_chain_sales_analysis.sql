CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    store_id INT,
    product_id INT,
    customer_id INT,
    quantity_sold INT,
    sale_amount DECIMAL(10, 2),
    FOREIGN KEY (sale_date) REFERENCES time(date),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
CREATE TABLE time (
    date DATE PRIMARY KEY,
    day_of_week VARCHAR(10),
    month INT,
    quarter INT,
    year INT
);
CREATE TABLE store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(255),
    store_location VARCHAR(255)
);
CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(255),
    price DECIMAL(10, 2)
);
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_email VARCHAR(255)
);
CREATE TABLE live_sales (
    sale_id INT PRIMARY KEY,
    sale_timestamp TIMESTAMP,
    store_id INT,
    product_id INT,
    customer_id INT,
    quantity_sold INT,
    sale_amount DECIMAL(10, 2),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
-- Extract and aggregate data from the OLTP system
WITH aggregated_sales AS (
    SELECT
        store_id,
        product_id,
        customer_id,
        sale_date,
        SUM(quantity_sold) AS total_quantity_sold,
        SUM(sale_amount) AS total_sale_amount
    FROM live_sales
    JOIN time ON live_sales.sale_timestamp::DATE = time.date
    GROUP BY store_id, product_id, customer_id, sale_date
)
-- Load the aggregated data into the fact_sales table
INSERT INTO fact_sales (sale_date, store_id, product_id, customer_id, quantity_sold, sale_amount)
SELECT sale_date, store_id, product_id, customer_id, total_quantity_sold, total_sale_amount
FROM aggregated_sales;
SELECT 
    store_name,
    product_name,
    SUM(quantity_sold) AS total_quantity_sold,
    SUM(sale_amount) AS total_sale_amount
FROM fact_sales fs
JOIN store s ON fs.store_id = s.store_id
JOIN product p ON fs.product_id = p.product_id
JOIN time t ON fs.sale_date = t.date
WHERE t.date = CURRENT_DATE
GROUP BY store_name, product_name;
SELECT 
    store_name,
    product_name,
    SUM(quantity_sold) AS total_quantity_sold,
    SUM(sale_amount) AS total_sale_amount
FROM fact_sales fs
JOIN store s ON fs.store_id = s.store_id
JOIN product p ON fs.product_id = p.product_id
JOIN time t ON fs.sale_date = t.date
WHERE t.year = EXTRACT(YEAR FROM CURRENT_DATE) AND t.month = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY store_name, product_name;
SELECT 
    store_name,
    product_name,
    SUM(quantity_sold) AS total_quantity_sold,
    SUM(sale_amount) AS total_sale_amount
FROM fact_sales fs
JOIN store s ON fs.store_id = s.store_id
JOIN product p ON fs.product_id = p.product_id
JOIN time t ON fs.sale_date = t.date
WHERE t.year = EXTRACT(YEAR FROM CURRENT_DATE) AND t.quarter = EXTRACT(QUARTER FROM CURRENT_DATE)
GROUP BY store_name, product_name;
