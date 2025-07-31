CREATE DATABASE school_db;
USE school_db;
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20) UNIQUE NOT NULL
);
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO students (first_name, last_name, dob, email)
VALUES
('John', 'Doe', '2000-01-15', 'john.doe@example.com'),
('Jane', 'Smith', '1999-07-30', 'jane.smith@example.com'),
('Tom', 'Jones', '2001-03-22', 'tom.jones@example.com'),
('Alice', 'Brown', '2000-11-12', 'alice.brown@example.com'),
('Mike', 'Davis', '2001-06-06', 'mike.davis@example.com'),
('Emily', 'Taylor', '1998-05-19', 'emily.taylor@example.com'),
('Chris', 'Wilson', '2000-10-02', 'chris.wilson@example.com'),
('Sophia', 'Miller', '1999-09-25', 'sophia.miller@example.com'),
('Liam', 'Moore', '2000-12-10', 'liam.moore@example.com'),
('Olivia', 'Anderson', '2001-01-30', 'olivia.anderson@example.com');
INSERT INTO courses (course_name, course_code)
VALUES
('Mathematics', 'MATH101'),
('Physics', 'PHYS101'),
('Chemistry', 'CHEM101'),
('Biology', 'BIOL101'),
('Computer Science', 'CS101'),
('History', 'HIST101'),
('English', 'ENG101'),
('Philosophy', 'PHIL101'),
('Geography', 'GEO101'),
('Economics', 'ECON101');
INSERT INTO teachers (first_name, last_name, email)
VALUES
('James', 'Williams', 'james.williams@example.com'),
('Laura', 'Johnson', 'laura.johnson@example.com'),
('David', 'Lee', 'david.lee@example.com'),
('Sarah', 'White', 'sarah.white@example.com'),
('John', 'King', 'john.king@example.com');
INSERT INTO enrollments (student_id, course_id)
VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5), (2, 6),
(3, 7), (3, 8),
(4, 9), (4, 10),
(5, 1), (5, 5), (5, 9),
(6, 2), (6, 6), (6, 8),
(7, 3), (7, 4),
(8, 5), (8, 7),
(9, 10),
(10, 1), (10, 3);
INSERT INTO students (first_name, last_name, dob, email)
VALUES ('Max', 'Garcia', '2002-04-21', 'max.garcia@example.com');
INSERT INTO enrollments (student_id, course_id)
VALUES (11, 3);  -- Max Garcia enrolls in Chemistry
UPDATE teachers
SET email = 'new.email@example.com'
WHERE teacher_id = 1;
SELECT c.course_name, s.first_name, s.last_name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
ORDER BY c.course_name;
SELECT c.course_name, COUNT(s.student_id) AS student_count
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY c.course_name;
SELECT s.first_name, s.last_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;
