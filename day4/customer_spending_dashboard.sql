-- Dashboard: Customer Spending Summary for Current Year
SELECT 
    c.customer_id,
    c.name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    -- Subquery in SELECT: Average Order Value
    (
        SELECT ROUND(AVG(order_total), 2)
        FROM (
            SELECT o2.order_id, SUM(oi2.quantity * oi2.price) AS order_total
            FROM orders o2
            JOIN order_items oi2 ON o2.order_id = oi2.order_id
            WHERE o2.customer_id = c.customer_id
            GROUP BY o2.order_id
        ) AS order_values
    ) AS avg_order_value,

    -- CASE: Spending Category
    CASE 
        WHEN (
            SELECT AVG(order_total)
            FROM (
                SELECT o2.order_id, SUM(oi2.quantity * oi2.price) AS order_total
                FROM orders o2
                JOIN order_items oi2 ON o2.order_id = oi2.order_id
                WHERE o2.customer_id = c.customer_id
                GROUP BY o2.order_id
            ) AS order_values
        ) > 500 THEN 'High Spender'
        WHEN (
            SELECT AVG(order_total)
            FROM (
                SELECT o2.order_id, SUM(oi2.quantity * oi2.price) AS order_total
                FROM orders o2
                JOIN order_items oi2 ON o2.order_id = oi2.order_id
                WHERE o2.customer_id = c.customer_id
                GROUP BY o2.order_id
            ) AS order_values
        ) BETWEEN 200 AND 500 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_category

FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY c.customer_id, c.name;
SELECT p.product_id, p.name,
       product_sales.total_revenue
FROM products p
JOIN (
    SELECT oi.product_id, SUM(oi.quantity * oi.price) AS total_revenue
    FROM order_items oi
    GROUP BY oi.product_id
) AS product_sales ON p.product_id = product_sales.product_id;
SELECT o.order_id, o.customer_id, o.order_date
FROM orders o
JOIN (
    SELECT o2.order_id, SUM(oi2.quantity * oi2.price) AS total_value
    FROM orders o2
    JOIN order_items oi2 ON o2.order_id = oi2.order_id
    GROUP BY o2.order_id
) AS order_totals ON o.order_id = order_totals.order_id
WHERE order_totals.total_value > (
    SELECT AVG(total_value)
    FROM (
        SELECT o3.order_id, SUM(oi3.quantity * oi3.price) AS total_value
        FROM orders o3
        JOIN order_items oi3 ON o3.order_id = oi3.order_id
        WHERE o3.customer_id = o.customer_id
        GROUP BY o3.order_id
    ) AS customer_order_avgs
);
SELECT customer_id, name, 'New' AS customer_type
FROM customers
WHERE signup_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)

UNION

SELECT customer_id, name, 'Old' AS customer_type
FROM customers
WHERE signup_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);


-- OR using INNER JOIN
SELECT DISTINCT o.customer_id
FROM orders o
JOIN reviews r ON o.customer_id = r.customer_id;
