-- Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    join_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Trainers Table
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    expertise VARCHAR(255) NOT NULL,
    hire_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Plans Table
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(255) NOT NULL,
    duration INT NOT NULL, -- duration in months
    price DECIMAL(10, 2) NOT NULL
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    plan_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- Sessions Table
CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    session_date DATETIME,
    trainer_id INT,
    member_id INT,
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);
-- Index on session_date for efficient searches on sessions by date
CREATE INDEX idx_session_date ON sessions(session_date);

-- Index on member_id for efficient lookups for specific members' session history
CREATE INDEX idx_member_id ON sessions(member_id);

-- Index on trainer_id for efficient queries related to specific trainers
CREATE INDEX idx_trainer_id ON sessions(trainer_id);
EXPLAIN
SELECT t.first_name, t.last_name, COUNT(s.session_id) AS total_sessions
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
WHERE s.session_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY t.trainer_id
ORDER BY total_sessions DESC;
SELECT m.first_name, m.last_name, COUNT(s.session_id) AS attendance_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id
HAVING attendance_count = (
    SELECT MAX(attendance_count)
    FROM (
        SELECT COUNT(session_id) AS attendance_count
        FROM sessions
        GROUP BY member_id
    ) AS subquery
);
-- Denormalized View for Trainer-wise Session Summary
CREATE VIEW trainer_session_summary AS
SELECT t.trainer_id, t.first_name AS trainer_first_name, t.last_name AS trainer_last_name,
       COUNT(s.session_id) AS total_sessions, COUNT(DISTINCT s.member_id) AS unique_members
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id;
SELECT m.first_name, m.last_name, COUNT(s.session_id) AS attendance_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id
ORDER BY attendance_count DESC
LIMIT 5;
EXPLAIN
SELECT t.first_name, t.last_name, COUNT(s.session_id) AS total_sessions
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
WHERE s.session_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY t.trainer_id
ORDER BY total_sessions DESC;
SELECT m.first_name, m.last_name, COUNT(s.session_id) AS attendance_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id
HAVING attendance_count = (
    SELECT MAX(attendance_count)
    FROM (
        SELECT COUNT(session_id) AS attendance_count
        FROM sessions
        GROUP BY member_id
    ) AS subquery
);
CREATE VIEW trainer_session_summary AS
SELECT t.trainer_id, t.first_name AS trainer_first_name, t.last_name AS trainer_last_name,
       COUNT(s.session_id) AS total_sessions, COUNT(DISTINCT s.member_id) AS unique_members
FROM trainers t
JOIN sessions s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id;
SELECT m.first_name, m.last_name, COUNT(s.session_id) AS attendance_count
FROM members m
JOIN sessions s ON m.member_id = s.member_id
GROUP BY m.member_id
ORDER BY attendance_count DESC
LIMIT 5;
