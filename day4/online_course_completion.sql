-- Table for Students
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    enrollment_date DATE
);

-- Table for Courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Table for Enrollments
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Table for Completion
CREATE TABLE completion (
    completion_id INT PRIMARY KEY,
    enrollment_id INT,
    score DECIMAL(5, 2),
    completion_date DATE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);
SELECT c.course_name, 
       (SELECT COUNT(*) FROM completion co
        JOIN enrollments e ON co.enrollment_id = e.enrollment_id
        WHERE e.course_id = c.course_id) AS completed_courses,
       (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.course_id) AS total_enrollments,
       ROUND((SELECT COUNT(*) FROM completion co
              JOIN enrollments e ON co.enrollment_id = e.enrollment_id
              WHERE e.course_id = c.course_id) * 100.0 / 
             (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.course_id), 2) AS completion_rate
FROM courses c;
SELECT s.student_id, s.name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN completion co ON e.enrollment_id = co.enrollment_id
WHERE c.course_name IN ('SQL', 'Python') 
GROUP BY s.student_id, s.name
HAVING COUNT(DISTINCT c.course_name) = 2;  -- Ensures both SQL and Python are completed

SELECT s.student_id, s.name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name IN ('Course 1', 'Course 2')

UNION

-- Students from Batch 2
SELECT s.student_id, s.name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE c.course_name IN ('Course 3', 'Course 4');
SELECT s.student_id, s.name, c.course_name, co.score,
       CASE
           WHEN co.score >= 90 THEN 'A'
           WHEN co.score >= 80 THEN 'B'
           WHEN co.score >= 70 THEN 'C'
           ELSE 'F'
       END AS grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN completion co ON e.enrollment_id = co.enrollment_id;
SELECT c.course_name, s.student_id, s.name, co.score
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
JOIN completion co ON e.enrollment_id = co.enrollment_id
WHERE co.score = (
    SELECT MAX(co2.score)
    FROM completion co2
    JOIN enrollments e2 ON co2.enrollment_id = e2.enrollment_id
    WHERE e2.course_id = c.course_id
)
ORDER BY c.course_name;
SELECT DATE_FORMAT(co.completion_date, '%Y-%m') AS completion_month, 
       COUNT(*) AS completions
FROM completion co
GROUP BY completion_month
ORDER BY completion_month DESC;
