CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    email VARCHAR(100),
    hire_date DATE,
    manager_id INT
);
SELECT name, salary, department
FROM employees
WHERE salary > 50000 AND department IN ('Sales', 'Marketing');
SELECT DISTINCT department
FROM employees;
SELECT *
FROM employees
WHERE name LIKE '%an';
SELECT *
FROM employees
WHERE manager_id IS NULL;
SELECT *
FROM employees
WHERE salary BETWEEN 40000 AND 80000;
SELECT *
FROM employees
ORDER BY department ASC, salary DESC;
