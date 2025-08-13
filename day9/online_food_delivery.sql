CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    driver_id INT,
    order_time TIMESTAMP,
    delivery_time TIMESTAMP,
    total_cost DECIMAL(10, 2),
    delivery_distance DECIMAL(5, 2), -- Distance in km
    food_category_id INT,
    region_id INT,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (food_category_id) REFERENCES dim_food_category(food_category_id),
    FOREIGN KEY (region_id) REFERENCES dim_region(region_id),
    FOREIGN KEY (order_time) REFERENCES dim_time(time_id),
    FOREIGN KEY (delivery_time) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    address VARCHAR(255)
);
CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(255),
    contact_number VARCHAR(20),
    vehicle_type VARCHAR(50)
);
CREATE TABLE dim_restaurant (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    cuisine_type VARCHAR(50),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);
CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255)
);
CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255)
);
CREATE TABLE dim_region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(255)
);
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    hour INT,
    day_of_week INT,
    week INT,
    month INT,
    quarter INT,
    year INT
);
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    hour INT,
    day_of_week INT,
    week INT,
    month INT,
    quarter INT,
    year INT
);
SELECT 
    r.region_name,
    AVG(EXTRACT(EPOCH FROM (f.delivery_time - f.order_time)) / 60) AS avg_delivery_time_minutes
FROM fact_orders f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY avg_delivery_time_minutes DESC;
SELECT 
    fc.category_name,
    COUNT(f.order_id) AS orders_count,
    SUM(f.total_cost) AS total_sales
FROM fact_orders f
JOIN dim_food_category fc ON f.food_category_id = fc.food_category_id
GROUP BY fc.category_name
ORDER BY total_sales DESC;
SELECT 
    r.restaurant_name,
    COUNT(f.order_id) AS order_count,
    SUM(f.total_cost) AS total_sales,
    AVG(EXTRACT(EPOCH FROM (f.delivery_time - f.order_time)) / 60) AS avg_delivery_time_minutes
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_sales DESC;
SELECT 
    l.city,
    COUNT(f.order_id) AS order_count,
    AVG(EXTRACT(EPOCH FROM (f.delivery_time - f.order_time)) / 60) AS avg_delivery_time
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_location l ON r.location_id = l.location_id
GROUP BY l.city
ORDER BY avg_delivery_time;
SELECT 
    r.restaurant_name,
    region.region_name,
    COUNT(f.order_id) AS order_count,
    SUM(f.total_cost) AS total_sales
FROM fact_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_region region ON f.region_id = region.region_id
GROUP BY r.restaurant_name, region.region_name
ORDER BY total_sales DESC;
