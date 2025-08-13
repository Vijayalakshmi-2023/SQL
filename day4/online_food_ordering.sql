SELECT 
    d.dish_id, 
    d.dish_name,
    (SELECT COUNT(o.dish_id) * 100.0 / (SELECT COUNT(*) FROM orders) 
     FROM orders o 
     WHERE o.dish_id = d.dish_id) AS popularity_percentage
FROM dishes d;
SELECT 
    area,
    SUM(order_count) AS total_orders
FROM (
    SELECT 
        r.area, 
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY r.area
) AS area_order_volume
GROUP BY area;
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    CASE
        WHEN COUNT(o.order_id) >= 10 THEN 'High'
        WHEN COUNT(o.order_id) BETWEEN 5 AND 9 THEN 'Medium'
        ELSE 'Low'
    END AS customer_bucket
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
SELECT 
    r.area,
    c.customer_name,
    MAX(o.total_amount) AS max_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.total_amount = (
    SELECT MAX(o2.total_amount)
    FROM orders o2
    WHERE o2.restaurant_id = r.restaurant_id
      AND o2.customer_id = c.customer_id
)
GROUP BY r.area, c.customer_name;
SELECT 
    order_id, 
    customer_id, 
    restaurant_id, 
    dish_id, 
    order_date, 
    order_type, 
    total_amount
FROM orders
WHERE order_type = 'delivery'

UNION ALL

SELECT 
    order_id, 
    customer_id, 
    restaurant_id, 
    dish_id, 
    order_date, 
    order_type, 
    total_amount
FROM orders
WHERE order_type = 'pickup';
SELECT 
    DATE(order_date) AS delivery_date,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_sales
FROM orders
WHERE order_type = 'delivery'
GROUP BY DATE(order_date)
ORDER BY delivery_date DESC;
