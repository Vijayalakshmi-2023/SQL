CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    teacher_id INT
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(5,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY,
    teacher_name VARCHAR(100)
);
SELECT course_id, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_id;
SELECT course_id, AVG(grade) AS avg_grade
FROM enrollments
GROUP BY course_id;
SELECT course_id, AVG(grade) AS avg_grade
FROM enrollments
GROUP BY course_id
HAVING AVG(grade) > 75;
SELECT s.student_name, c.course_name, e.grade
FROM enrollments e
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN courses c ON e.course_id = c.course_id;
SELECT c.course_id, c.course_name, e.enrollment_id
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;
SELECT 
    e1.student_id AS student1_id, s1.student_name AS student1_name,
    e2.student_id AS student2_id, s2.student_name AS student2_name,
    e1.course_id, e1.grade
FROM enrollments e1
JOIN enrollments e2 ON e1.course_id = e2.course_id AND e1.grade = e2.grade AND e1.student_id <> e2.student_id
JOIN students s1 ON e1.student_id = s1.student_id
JOIN students s2 ON e2.student_id = s2.student_id
ORDER BY e1.course_id, e1.grade;
