CREATE TABLE Sales (
    sales_id INT,
    region VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    sales_date DATE,
    revenue DECIMAL(10, 2)
);
WITH RECURSIVE LocationHierarchy AS (
    -- Base case: Regions
    SELECT region AS location, NULL AS parent_location, 'Region' AS level
    FROM Sales
    GROUP BY region

    UNION ALL

    -- Recursive case: States
    SELECT s.state AS location, lh.location AS parent_location, 'State' AS level
    FROM Sales s
    JOIN LocationHierarchy lh ON s.region = lh.location

    UNION ALL

    -- Recursive case: Cities
    SELECT s.city AS location, lh.location AS parent_location, 'City' AS level
    FROM Sales s
    JOIN LocationHierarchy lh ON s.state = lh.location
)
SELECT * FROM LocationHierarchy;
WITH WeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        WEEK(sales_date) AS week,
        SUM(revenue) AS weekly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), WEEK(sales_date)
)
SELECT * FROM WeeklyPerformance;
WITH MonthlyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        MONTH(sales_date) AS month,
        SUM(revenue) AS monthly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), MONTH(sales_date)
)
SELECT * FROM MonthlyPerformance;
WITH WeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        WEEK(sales_date) AS week,
        SUM(revenue) AS weekly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), WEEK(sales_date)
),
RankedWeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        weekly_revenue,
        RANK() OVER (PARTITION BY WEEK(sales_date) ORDER BY SUM(revenue) DESC) AS weekly_sales_rank,
        DENSE_RANK() OVER (PARTITION BY WEEK(sales_date) ORDER BY SUM(revenue) DESC) AS dense_weekly_sales_rank
    FROM WeeklyPerformance
)
SELECT * FROM RankedWeeklyPerformance;
WITH MonthlyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        MONTH(sales_date) AS month,
        SUM(revenue) AS monthly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), MONTH(sales_date)
),
RankedMonthlyPerformance AS (
    SELECT
        region,
        state,
        city,
        monthly_revenue,
        RANK() OVER (PARTITION BY MONTH(sales_date) ORDER BY SUM(revenue) DESC) AS monthly_sales_rank,
        DENSE_RANK() OVER (PARTITION BY MONTH(sales_date) ORDER BY SUM(revenue) DESC) AS dense_monthly_sales_rank
    FROM MonthlyPerformance
)
SELECT * FROM RankedMonthlyPerformance;
WITH WeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        WEEK(sales_date) AS week,
        SUM(revenue) AS weekly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), WEEK(sales_date)
),
WeeklyComparison AS (
    SELECT
        region,
        state,
        city,
        week,
        weekly_revenue,
        LAG(weekly_revenue) OVER (PARTITION BY region ORDER BY week) AS previous_week_revenue
    FROM WeeklyPerformance
)
SELECT 
    region,
    state,
    city,
    week,
    weekly_revenue,
    previous_week_revenue,
    weekly_revenue - previous_week_revenue AS revenue_change
FROM WeeklyComparison
WHERE previous_week_revenue IS NOT NULL;
WITH WeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        WEEK(sales_date) AS week,
        SUM(revenue) AS weekly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), WEEK(sales_date)
),
TopPerformers AS (
    SELECT
        region,
        state,
        city,
        weekly_revenue,
        RANK() OVER (PARTITION BY week ORDER BY weekly_revenue DESC) AS region_rank
    FROM WeeklyPerformance
)
SELECT
    region,
    state,
    city,
    weekly_revenue,
    region_rank,
    CASE 
        WHEN region_rank = 1 THEN 'Top Performer'
        ELSE 'Other Region'
    END AS performance_flag
FROM TopPerformers;
WITH RECURSIVE LocationHierarchy AS (
    SELECT region AS location, NULL AS parent_location, 'Region' AS level
    FROM Sales
    GROUP BY region
    UNION ALL
    SELECT s.state AS location, lh.location AS parent_location, 'State' AS level
    FROM Sales s
    JOIN LocationHierarchy lh ON s.region = lh.location
    UNION ALL
    SELECT s.city AS location, lh.location AS parent_location, 'City' AS level
    FROM Sales s
    JOIN LocationHierarchy lh ON s.state = lh.location
),
WeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        YEAR(sales_date) AS year,
        WEEK(sales_date) AS week,
        SUM(revenue) AS weekly_revenue
    FROM Sales
    GROUP BY region, state, city, YEAR(sales_date), WEEK(sales_date)
),
WeeklyComparison AS (
    SELECT
        region,
        state,
        city,
        week,
        weekly_revenue,
        LAG(weekly_revenue) OVER (PARTITION BY region ORDER BY week) AS previous_week_revenue
    FROM WeeklyPerformance
),
RankedWeeklyPerformance AS (
    SELECT
        region,
        state,
        city,
        weekly_revenue,
        RANK() OVER (PARTITION BY WEEK(sales_date) ORDER BY SUM(revenue) DESC) AS weekly_sales_rank,
        DENSE_RANK() OVER (PARTITION BY WEEK(sales_date) ORDER BY SUM(revenue) DESC) AS dense_weekly_sales_rank
    FROM WeeklyPerformance
)
SELECT 
    region,
    state,
    city,
    weekly_revenue,
    previous_week_revenue,
    weekly_revenue - previous_week_revenue AS revenue_change,
    region_rank,
    CASE 
        WHEN region_rank = 1 THEN 'Top Performer'
        ELSE 'Other Region'
    END AS performance_flag
FROM WeeklyComparison
JOIN RankedWeeklyPerformance ON WeeklyComparison.region = RankedWeeklyPerformance.region;
