CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    plan_type VARCHAR(50),
    start_date DATE,
    status VARCHAR(20)    -- e.g., 'Active', 'Inactive', or NULL
);
SELECT name, age, plan_type
FROM members
WHERE status = 'Active' AND age BETWEEN 20 AND 40;
SELECT DISTINCT plan_type
FROM members;
SELECT *
FROM members
WHERE name LIKE 'S%';
SELECT *
FROM members
WHERE status IS NULL;
SELECT *
FROM members
ORDER BY age ASC, name ASC;
