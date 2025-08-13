CREATE TABLE Employee_Promotions (
    emp_id INT,
    name VARCHAR(100),
    role VARCHAR(100),
    salary DECIMAL(10, 2),
    promotion_date DATE,
    manager_id INT -- manager_id will reference emp_id of the manager
);
INSERT INTO Employee_Promotions (emp_id, name, role, salary, promotion_date, manager_id)
VALUES
(1, 'Alice', 'Junior Developer', 50000, '2020-01-15', NULL),
(1, 'Alice', 'Senior Developer', 70000, '2021-06-01', 3),
(1, 'Alice', 'Lead Developer', 90000, '2023-01-01', 4),
(2, 'Bob', 'Junior Developer', 45000, '2020-05-20', NULL),
(2, 'Bob', 'Senior Developer', 65000, '2022-03-15', 3),
(3, 'Charlie', 'Manager', 100000, '2018-09-10', NULL),
(4, 'David', 'Senior Developer', 72000, '2020-08-01', 3);
WITH RankedPromotions AS (
    SELECT
        emp_id,
        name,
        role,
        salary,
        promotion_date,
        ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY promotion_date) AS promotion_rank
    FROM Employee_Promotions
)
SELECT * FROM RankedPromotions;
WITH PromotionComparisons AS (
    SELECT
        emp_id,
        name,
        role,
        salary,
        promotion_date,
        LEAD(role) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_role,
        LEAD(salary) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_salary
    FROM Employee_Promotions
)
SELECT * FROM PromotionComparisons;
WITH PromotionTimes AS (
    SELECT
        emp_id,
        name,
        promotion_date,
        LEAD(promotion_date) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_promotion_date
    FROM Employee_Promotions
)
SELECT 
    emp_id,
    name,
    promotion_date,
    next_promotion_date,
    DATEDIFF(next_promotion_date, promotion_date) AS days_between_promotions
FROM PromotionTimes
WHERE next_promotion_date IS NOT NULL;
WITH RECURSIVE ManagerChain AS (
    SELECT
        emp_id,
        name,
        manager_id,
        1 AS level
    FROM Employee_Promotions
    WHERE manager_id IS NULL -- Top-level managers
    
    UNION ALL
    
    SELECT
        e.emp_id,
        e.name,
        e.manager_id,
        mc.level + 1 AS level
    FROM Employee_Promotions e
    JOIN ManagerChain mc ON e.manager_id = mc.emp_id
)
SELECT * FROM ManagerChain;
WITH PromotionDurations AS (
    SELECT
        emp_id,
        name,
        promotion_date,
        LEAD(promotion_date) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_promotion_date,
        DATEDIFF(LEAD(promotion_date) OVER (PARTITION BY emp_id ORDER BY promotion_date), promotion_date) AS days_between_promotions
    FROM Employee_Promotions
)
SELECT 
    emp_id,
    name,
    promotion_date,
    next_promotion_date,
    days_between_promotions,
    RANK() OVER (ORDER BY days_between_promotions ASC) AS promotion_speed_rank
FROM PromotionDurations
WHERE next_promotion_date IS NOT NULL;
WITH RankedPromotions AS (
    SELECT
        emp_id,
        name,
        role,
        salary,
        promotion_date,
        ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY promotion_date) AS promotion_rank
    FROM Employee_Promotions
),
PromotionComparisons AS (
    SELECT
        emp_id,
        name,
        role,
        salary,
        promotion_date,
        LEAD(role) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_role,
        LEAD(salary) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_salary
    FROM Employee_Promotions
),
PromotionTimes AS (
    SELECT
        emp_id,
        name,
        promotion_date,
        LEAD(promotion_date) OVER (PARTITION BY emp_id ORDER BY promotion_date) AS next_promotion_date
    FROM Employee_Promotions
)
SELECT 
    r.emp_id,
    r.name,
    r.promotion_rank,
    c.next_role,
    c.next_salary,
    t.next_promotion_date,
    DATEDIFF(t.next_promotion_date, r.promotion_date) AS days_between_promotions
FROM RankedPromotions r
JOIN PromotionComparisons c ON r.emp_id = c.emp_id
JOIN PromotionTimes t ON r.emp_id = t.emp_id
WHERE t.next_promotion_date IS NOT NULL;
