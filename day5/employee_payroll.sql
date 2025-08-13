-- Table for Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Table for Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,  -- UNIQUE constraint on email
    department_id INT,
    hire_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Table for Salaries
CREATE TABLE salaries (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    salary DECIMAL(15, 2) CHECK (salary > 10000),  -- CHECK constraint on salary
    salary_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
INSERT INTO employees (employee_id, name, email, department_id, hire_date)
VALUES (1, 'John Doe', 'john.doe@example.com', 2, '2025-01-15');
UPDATE salaries
SET salary = salary * 1.10  -- 10% salary increase for promotion
WHERE employee_id = 1;
DELETE FROM employees
WHERE employee_id = 1;
ALTER TABLE salaries
ADD CONSTRAINT salary_check CHECK (salary > 10000);
-- Dropping the existing constraint (if needed)
ALTER TABLE employees DROP CONSTRAINT employees_email_check;

-- Adding a new length constraint on email (assuming we want to change the length to 200 characters)
ALTER TABLE employees
MODIFY email VARCHAR(200) NOT NULL;
-- Drop the email length constraint (if applicable)
ALTER TABLE employees
DROP COLUMN email;
-- Start a transaction
BEGIN;

-- Set a savepoint before starting the bulk insert
SAVEPOINT before_bonus_insertion;

-- Inserting bonus amounts for multiple employees
INSERT INTO salaries (employee_id, salary, salary_date)
VALUES 
    (2, 15000, '2025-08-01'),
    (3, 20000, '2025-08-01'),
    (4, 25000, '2025-08-01');

-- Simulating an error (e.g., one of the bonus entries is invalid)
-- You can force an error here (like a constraint violation) for testing purposes.

-- If an error occurs, roll back to the savepoint
-- ROLLBACK TO before_bonus_insertion;

-- Commit the transaction if everything is successful
COMMIT;
