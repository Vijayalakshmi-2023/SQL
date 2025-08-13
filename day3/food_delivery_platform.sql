CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    restaurant_id INT,
    delivery_agent_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (delivery_agent_id) REFERENCES delivery_agents(delivery_agent_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE delivery_agents (
    delivery_agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100)
);
SELECT restaurant_id, COUNT(*) AS total_orders
FROM orders
GROUP BY restaurant_id;
SELECT delivery_agent_id, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY delivery_agent_id;
SELECT restaurant_id, SUM(total_amount) AS revenue
FROM orders
GROUP BY restaurant_id
HAVING SUM(total_amount) > 50000;
SELECT r.name AS restaurant_name, o.order_id, o.total_amount, o.order_date
FROM restaurants r
INNER JOIN orders o ON r.restaurant_id = o.restaurant_id;
SELECT da.delivery_agent_id, da.agent_name, o.order_id, o.total_amount
FROM delivery_agents da
LEFT JOIN orders o ON da.delivery_agent_id = o.delivery_agent_id;
SELECT 
    r1.restaurant_id AS restaurant1_id, r1.name AS restaurant1_name, r1.location,
    r2.restaurant_id AS restaurant2_id, r2.name AS restaurant2_name
FROM restaurants r1
JOIN restaurants r2 ON r1.location = r2.location AND r1.restaurant_id <> r2.restaurant_id
ORDER BY r1.location, r1.restaurant_id;
