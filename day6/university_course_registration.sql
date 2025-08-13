-- Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    contact_number VARCHAR(15)
);

-- Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL UNIQUE
);

-- Faculty Table
CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    department_id INT,
    email VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Courses Table
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    department_id INT,
    faculty_id INT,
    credits INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id)
);

-- Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
-- Index on student_id for fast lookups in enrollments
CREATE INDEX idx_student_id ON enrollments(student_id);

-- Index on course_id for fast lookups in enrollments
CREATE INDEX idx_course_id ON enrollments(course_id);

-- Index on faculty_id for fast lookups in courses
CREATE INDEX idx_faculty_id ON courses(faculty_id);
EXPLAIN 
SELECT s.first_name, s.last_name, c.course_name, e.enrollment_date
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.student_id = ?
ORDER BY e.enrollment_date;
SELECT student_id, COUNT(course_id) AS course_count
FROM enrollments
GROUP BY student_id
HAVING course_count > 3;
-- Denormalized View for Student Performance Summary
CREATE VIEW student_performance_summary AS
SELECT s.student_id, 
       s.first_name AS student_first_name, 
       s.last_name AS student_last_name, 
       COUNT(e.course_id) AS total_courses_enrolled,
       d.department_name AS department_name,
       f.first_name AS faculty_first_name,
       f.last_name AS faculty_last_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
JOIN faculty f ON c.faculty_id = f.faculty_id
GROUP BY s.student_id, d.department_name, f.faculty_id;
SELECT course_id, course_name, credits
FROM courses
ORDER BY course_name
LIMIT 10 OFFSET 0;  -- Adjust the OFFSET for pagination (e.g., for page 2, OFFSET would be 10)
