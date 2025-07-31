CREATE DATABASE gym_db;
USE gym_db;
CREATE TABLE plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    duration_months INT NOT NULL,  -- Duration of the plan in months
    price DECIMAL(10, 2) NOT NULL
);
CREATE TABLE trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    trainer_id INT,
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);
CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    plan_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Active', 'Expired') DEFAULT 'Active',
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);
INSERT INTO plans (plan_name, duration_months, price) VALUES
('Basic Plan', 1, 30.00),
('Silver Plan', 3, 80.00),
('Gold Plan', 6, 150.00),
('Platinum Plan', 12, 250.00),
('VIP Plan', 12, 500.00);
INSERT INTO trainers (trainer_name, specialization) VALUES
('John Doe', 'Weight Training'),
('Jane Smith', 'Cardio'),
('Mike Johnson', 'Yoga');
INSERT INTO members (first_name, last_name, email, trainer_id) VALUES
('Alice', 'Johnson', 'alice.johnson@fitness.com', 1),
('Bob', 'Smith', 'bob.smith@fitness.com', 2),
('Charlie', 'Davis', 'charlie.davis@fitness.com', 3),
('David', 'Martinez', 'david.martinez@fitness.com', 1),
('Emily', 'Garcia', 'emily.garcia@fitness.com', 2),
('Frank', 'Miller', 'frank.miller@fitness.com', 1),
('Grace', 'Wilson', 'grace.wilson@fitness.com', 3),
('Hannah', 'Lopez', 'hannah.lopez@fitness.com', 2),
('Ivy', 'Anderson', 'ivy.anderson@fitness.com', 3),
('Jack', 'Thomas', 'jack.thomas@fitness.com', 1);
INSERT INTO subscriptions (member_id, plan_id, start_date, end_date, status) VALUES
(1, 1, '2023-01-01', '2023-02-01', 'Active'),
(2, 3, '2023-03-01', '2023-09-01', 'Active'),
(3, 2, '2023-02-01', '2023-05-01', 'Expired'),
(4, 4, '2023-04-01', '2024-04-01', 'Active'),
(5, 5, '2023-06-01', '2024-06-01', 'Active');
UPDATE subscriptions
SET plan_id = 3, start_date = '2023-07-01', end_date = '2023-12-01'
WHERE member_id = 1 AND status = 'Active';
DELETE FROM subscriptions
WHERE status = 'Expired';
SELECT m.first_name, m.last_name, p.plan_name, s.start_date, s.end_date, s.status
FROM members m
JOIN subscriptions s ON m.member_id = s.member_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.status = 'Active';
SELECT m.first_name, m.last_name, m.email
FROM members m
LEFT JOIN subscriptions s ON m.member_id = s.member_id AND s.status = 'Active'
WHERE s.subscription_id IS NULL;
SELECT trainer_name, specialization FROM trainers;
