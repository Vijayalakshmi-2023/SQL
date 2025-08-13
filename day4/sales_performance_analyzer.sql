SELECT 
    st.store_id,
    st.store_name,
    SUM(s.sale_amount) AS store_revenue,
    ROUND(
        (SUM(s.sale_amount) / (
            SELECT SUM(s2.sale_amount)
            FROM sales s2
        )) * 100, 2
    ) AS revenue_percentage
FROM stores st
JOIN sales s ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name;
SELECT 
    e.region, 
    e.employee_name, 
    SUM(s.sale_amount) AS total_sales
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
WHERE s.sale_amount = (
    SELECT MAX(s2.sale_amount)
    FROM sales s2
    WHERE s2.employee_id = e.employee_id
      AND MONTH(s2.sale_date) = MONTH(s.sale_date)
      AND YEAR(s2.sale_date) = YEAR(s.sale_date)
)
GROUP BY e.region, e.employee_name;
SELECT store_id, product_id, sale_date, sale_amount, 'online' AS sale_channel
FROM sales
WHERE sale_type = 'online'

UNION

SELECT store_id, product_id, sale_date, sale_amount, 'offline' AS sale_channel
FROM sales
WHERE sale_type = 'offline';
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.sale_amount) AS total_sales,
    CASE 
        WHEN SUM(s.sale_amount) >= 10000 THEN 'Top Seller'
        WHEN SUM(s.sale_amount) BETWEEN 5000 AND 9999 THEN 'Medium'
        ELSE 'Low'
    END AS sales_category
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;
SELECT 
    YEAR(s.sale_date) AS sale_year,
    MONTH(s.sale_date) AS sale_month,
    SUM(s.sale_amount) AS total_sales
FROM sales s
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
ORDER BY sale_year DESC, sale_month DESC;
SELECT 
    st.store_id,
    st.store_name,
    SUM(s.sale_amount) AS total_sales,
    COUNT(s.sale_id) AS num_sales
FROM stores st
JOIN sales s ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name;
