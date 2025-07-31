CREATE DATABASE exam_db;
USE exam_db;
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    subject_id INT,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);
CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    marks_obtained DECIMAL(5, 2),
    exam_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);
INSERT INTO students (first_name, last_name, date_of_birth, email) VALUES
('Alice', 'Brown', '2005-03-15', 'alice.brown@example.com'),
('Bob', 'Smith', '2004-07-21', 'bob.smith@example.com'),
('Charlie', 'Davis', '2005-11-05', 'charlie.davis@example.com'),
('David', 'Martinez', '2004-09-30', 'david.martinez@example.com'),
('Emily', 'Wilson', '2005-01-10', 'emily.wilson@example.com');
INSERT INTO subjects (subject_name) VALUES
('Mathematics'),
('Physics'),
('Chemistry'),
('English'),
('History');
INSERT INTO teachers (first_name, last_name, subject_id) VALUES
('John', 'Doe', 1),  -- Teacher for Mathematics
('Jane', 'Smith', 2),  -- Teacher for Physics
('Sam', 'Brown', 3),  -- Teacher for Chemistry
('Rachel', 'White', 4),  -- Teacher for English
('Michael', 'Johnson', 5);  -- Teacher for History
INSERT INTO marks (student_id, subject_id, marks_obtained, exam_date) VALUES
(1, 1, 85.50, '2023-05-15'),
(1, 2, 90.00, '2023-05-15'),
(1, 3, 78.00, '2023-05-15'),
(1, 4, 92.00, '2023-05-15'),
(1, 5, 88.00, '2023-05-15'),
(2, 1, 75.00, '2023-05-15'),
(2, 2, 80.50, '2023-05-15'),
(2, 3, 84.00, '2023-05-15'),
(2, 4, 89.00, '2023-05-15'),
(2, 5, 77.50, '2023-05-15'),
(3, 1, 88.00, '2023-05-15'),
(3, 2, 79.50, '2023-05-15'),
(3, 3, 92.00, '2023-05-15'),
(3, 4, 85.00, '2023-05-15'),
(3, 5, 94.00, '2023-05-15'),
(4, 1, 70.00, '2023-05-15'),
(4, 2, 76.00, '2023-05-15'),
(4, 3, 80.00, '2023-05-15'),
(4, 4, 95.00, '2023-05-15'),
(4, 5, 82.00, '2023-05-15'),
(5, 1, 90.00, '2023-05-15'),
(5, 2, 85.00, '2023-05-15'),
(5, 3, 87.00, '2023-05-15'),
(5, 4, 91.00, '2023-05-15'),
(5, 5, 78.00, '2023-05-15');
SELECT s.first_name, s.last_name, AVG(m.marks_obtained) AS average_marks
FROM students s
JOIN marks m ON s.student_id = m.student_id
GROUP BY s.student_id
ORDER BY average_marks DESC;
SELECT s.first_name, s.last_name, su.subject_name, m.marks_obtained,
       RANK() OVER (PARTITION BY su.subject_id ORDER BY m.marks_obtained DESC) AS rank
FROM marks m
JOIN students s ON m.student_id = s.student_id
JOIN subjects su ON m.subject_id = su.subject_id
ORDER BY su.subject_name, rank;
