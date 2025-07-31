CREATE DATABASE course_portal;
USE course_portal;
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_description TEXT
);
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);
CREATE TABLE registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO courses (course_name, course_description) VALUES
('Introduction to Python', 'Learn the basics of Python programming.'),
('Data Structures and Algorithms', 'Understand key data structures and algorithms.'),
('Web Development with HTML & CSS', 'Learn how to build web pages using HTML and CSS.'),
('Database Management Systems', 'Understand the fundamentals of database design and SQL.'),
('Machine Learning Basics', 'Learn the fundamentals of machine learning and AI.');
INSERT INTO students (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice.johnson@student.com'),
('Bob', 'Smith', 'bob.smith@student.com'),
('Charlie', 'Davis', 'charlie.davis@student.com'),
('David', 'Martinez', 'david.martinez@student.com'),
('Emily', 'Garcia', 'emily.garcia@student.com'),
('Frank', 'Miller', 'frank.miller@student.com'),
('Grace', 'Wilson', 'grace.wilson@student.com'),
('Hannah', 'Lopez', 'hannah.lopez@student.com');
INSERT INTO instructors (instructor_name, specialization) VALUES
('Dr. John Doe', 'Python and Data Science'),
('Dr. Jane Smith', 'Web Development'),
('Dr. Mark Lee', 'Machine Learning');
INSERT INTO registrations (student_id, course_id) VALUES
(1, 1),  -- Alice registered for Introduction to Python
(1, 3),  -- Alice registered for Web Development with HTML & CSS
(2, 1),  -- Bob registered for Introduction to Python
(3, 2),  -- Charlie registered for Data Structures and Algorithms
(4, 4),  -- David registered for Database Management Systems
(5, 1),  -- Emily registered for Introduction to Python
(6, 5),  -- Frank registered for Machine Learning Basics
(7, 2),  -- Grace registered for Data Structures and Algorithms
(8, 3),  -- Hannah registered for Web Development with HTML & CSS
(2, 5);  -- Bob registered for Machine Learning Basics
SELECT c.course_name, COUNT(r.student_id) AS student_count
FROM courses c
LEFT JOIN registrations r ON c.course_id = r.course_id
GROUP BY c.course_id;
SELECT s.first_name, s.last_name, s.email
FROM students s
LEFT JOIN registrations r ON s.student_id = r.student_id
WHERE r.course_id IS NULL;
