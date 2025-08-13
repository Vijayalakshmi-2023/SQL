CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(255)
);
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    sale_date DATE,
    quantity INT,
    sale_amount DECIMAL(10, 2),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
WITH WeeklySales AS (
    SELECT
        p.product_id,
        p.product_name,
        EXTRACT(ISOYEAR FROM s.sale_date) AS sale_year,
        EXTRACT(ISOWeek FROM s.sale_date) AS sale_week,
        SUM(s.quantity) AS total_sales,
        SUM(s.sale_amount) AS total_revenue
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, sale_year, sale_week
),
MonthlySales AS (
    SELECT
        p.product_id,
        p.product_name,
        EXTRACT(ISOYEAR FROM s.sale_date) AS sale_year,
        EXTRACT(MONTH FROM s.sale_date) AS sale_month,
        SUM(s.quantity) AS total_sales,
        SUM(s.sale_amount) AS total_revenue
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, sale_year, sale_month
),
WeeklyRanked AS (
    SELECT 
        product_id,
        product_name,
        sale_year,
        sale_week,
        total_sales,
        total_revenue,
        RANK() OVER (PARTITION BY sale_year, sale_week ORDER BY total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (PARTITION BY sale_year, sale_week ORDER BY total_sales DESC) AS dense_sales_rank
    FROM WeeklySales
),
MonthlyRanked AS (
    SELECT 
        product_id,
        product_name,
        sale_year,
        sale_month,
        total_sales,
        total_revenue,
        RANK() OVER (PARTITION BY sale_year, sale_month ORDER BY total_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (PARTITION BY sale_year, sale_month ORDER BY total_sales DESC) AS dense_sales_rank
    FROM MonthlySales
)
SELECT 
    product_id,
    product_name,
    sale_year,
    sale_week,
    total_sales AS weekly_sales,
    total_revenue AS weekly_revenue,
    sales_rank AS weekly_sales_rank,
    dense_sales_rank AS weekly_dense_sales_rank,
    sale_month,
    monthly_sales,
    monthly_revenue,
    monthly_sales_rank,
    monthly_dense_sales_rank
FROM WeeklyRanked wr
JOIN MonthlyRanked mr ON wr.product_id = mr.product_id
ORDER BY sale_year, sale_week, sale_month, sales_rank;
