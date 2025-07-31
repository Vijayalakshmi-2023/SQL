CREATE DATABASE company_hr;
USE company_hr;
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    date DATE NOT NULL,
    in_time TIME,
    out_time TIME,
    status ENUM('Present', 'Absent', 'Leave') DEFAULT 'Present',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
INSERT INTO departments (department_name) VALUES
('HR'),
('Finance'),
('IT'),
('Sales'),
('Marketing');
INSERT INTO employees (first_name, last_name, email, department_id) VALUES
('Alice', 'Johnson', 'alice.johnson@company.com', 1),
('Bob', 'Smith', 'bob.smith@company.com', 2),
('Charlie', 'Davis', 'charlie.davis@company.com', 3),
('David', 'Martinez', 'david.martinez@company.com', 4),
('Emily', 'Garcia', 'emily.garcia@company.com', 5),
('Frank', 'Miller', 'frank.miller@company.com', 1),
('Grace', 'Wilson', 'grace.wilson@company.com', 2),
('Hannah', 'Lopez', 'hannah.lopez@company.com', 3),
('Ivy', 'Anderson', 'ivy.anderson@company.com', 4),
('Jack', 'Thomas', 'jack.thomas@company.com', 5),
('Liam', 'Martinez', 'liam.martinez@company.com', 1),
('Megan', 'Lee', 'megan.lee@company.com', 2),
('Noah', 'King', 'noah.king@company.com', 3),
('Olivia', 'Young', 'olivia.young@company.com', 4),
('Paul', 'Taylor', 'paul.taylor@company.com', 5);
INSERT INTO attendance (employee_id, date, in_time, out_time, status) VALUES
(1, '2023-07-01', '09:00:00', '17:00:00', 'Present'),
(2, '2023-07-01', '09:15:00', '17:10:00', 'Present'),
(3, '2023-07-01', '09:05:00', '17:00:00', 'Present'),
(4, '2023-07-01', '09:10:00', '17:15:00', 'Present'),
(5, '2023-07-01', '09:00:00', '17:00:00', 'Present'),
(6, '2023-07-01', '09:00:00', '17:00:00', 'Present'),
(7, '2023-07-01', '09:00:00', '17:05:00', 'Present'),
(8, '2023-07-01', '09:00:00', '17:00:00', 'Absent'),
(9, '2023-07-01', '09:00:00', '17:00:00', 'Present'),
(10, '2023-07-01', '09:00:00', '17:00:00', 'Present'),
(1, '2023-07-02', '09:05:00', '17:00:00', 'Present'),
(2, '2023-07-02', '09:00:00', '17:00:00', 'Absent'),
(3, '2023-07-02', '09:00:00', '17:00:00', 'Present'),
(4, '2023-07-02', '09:00:00', '17:00:00', 'Leave'),
(5, '2023-07-02', '09:10:00', '17:10:00', 'Present'),
(6, '2023-07-02', '09:00:00', '17:00:00', 'Present'),
(7, '2023-07-02', '09:05:00', '17:00:00', 'Present'),
(8, '2023-07-02', '09:00:00', '17:00:00', 'Absent'),
(9, '2023-07-02', '09:00:00', '17:05:00', 'Present'),
(10, '2023-07-02', '09:10:00', '17:00:00', 'Present'),
(1, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(2, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(3, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(4, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(5, '2023-07-03', '09:00:00', '17:00:00', 'Absent'),
(6, '2023-07-03', '09:05:00', '17:00:00', 'Present'),
(7, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(8, '2023-07-03', '09:00:00', '17:00:00', 'Leave'),
(9, '2023-07-03', '09:00:00', '17:00:00', 'Present'),
(10, '2023-07-03', '09:00:00', '17:00:00', 'Present');
SELECT e.first_name, e.last_name, a.date,
       TIMEDIFF(a.out_time, a.in_time) AS working_hours
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
WHERE a.date = '2023-07-01';
SELECT e.first_name, e.last_name,
       SUM(CASE WHEN a.status = 'Leave' THEN 1 ELSE 0 END) AS leave_days
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
GROUP BY e.employee_id;
