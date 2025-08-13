CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2),
    department_id INT,
    manager_id INT,   -- refers to emp_id of manager
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;
SELECT e.emp_id, e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
SELECT d.department_id, d.department_name, e.emp_id
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.emp_id IS NULL;
SELECT e1.emp_id, e1.name AS employee_name, e2.name AS manager_name
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;
