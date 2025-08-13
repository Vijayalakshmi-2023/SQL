CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (order_date) REFERENCES time(date)
);
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id)
);
CREATE TABLE dim_region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(255)
);
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    brand_id INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (brand_id) REFERENCES dim_brand(brand_id)
);
CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);
CREATE TABLE dim_brand (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(255)
);
CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(10)
);
-- Extract and Aggregate Data from OLTP Tables
WITH order_details AS (
    SELECT
        o.order_id,
        o.order_date,
        o.customer_id,
        oi.product_id,
        oi.quantity,
        (oi.quantity * p.price) AS order_amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
),
-- Cleaned Data for Loading
cleaned_data AS (
    SELECT
        od.order_id,
        od.order_date,
        od.customer_id,
        od.product_id,
        od.quantity,
        od.order_amount,
        -- Extract time info
        EXTRACT(YEAR FROM od.order_date) AS year,
        EXTRACT(QUARTER FROM od.order_date) AS quarter,
        EXTRACT(MONTH FROM od.order_date) AS month,
        EXTRACT(DAY FROM od.order_date) AS day,
        TO_CHAR(od.order_date, 'Day') AS day_of_week
    FROM order_details od
)
-- Insert into fact_orders
INSERT INTO fact_orders (order_id, order_date, customer_id, product_id, quantity, order_amount)
SELECT 
    order_id,
    order_date,
    customer_id,
    product_id,
    quantity,
    order_amount
FROM cleaned_data;
SELECT 
    p.product_name,
    SUM(fo.quantity) AS total_quantity_sold,
    SUM(fo.order_amount) AS total_sales
FROM fact_orders fo
JOIN dim_product p ON fo.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;
SELECT 
    t.quarter,
    SUM(fo.order_amount) AS total_sales
FROM fact_orders fo
JOIN dim_time t ON fo.order_date = t.date
GROUP BY t.quarter
ORDER BY t.quarter;
-- Drill-down from Quarterly to Monthly Sales
SELECT 
    t.month,
    SUM(fo.order_amount) AS total_sales
FROM fact_orders fo
JOIN dim_time t ON fo.order_date = t.date
WHERE t.quarter = 1  -- Drill down for Q1
GROUP BY t.month
ORDER BY t.month;
-- Roll-up from Daily to Monthly Sales
SELECT 
    t.month,
    SUM(fo.order_amount) AS total_sales
FROM fact_orders fo
JOIN dim_time t ON fo.order_date = t.date
GROUP BY t.month
ORDER BY t.month;
