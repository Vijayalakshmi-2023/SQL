CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(200),
    instructor_id INT
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    completion_status BOOLEAN,  -- TRUE if completed, FALSE otherwise
    completion_date DATE
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100)
);
SELECT course_id, COUNT(*) AS total_enrollments
FROM enrollments
GROUP BY course_id;
SELECT i.instructor_id, i.instructor_name,
       AVG(CASE WHEN e.completion_status = TRUE THEN 1 ELSE 0 END) AS avg_completion_rate
FROM instructors i
JOIN courses c ON i.instructor_id = c.instructor_id
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY i.instructor_id, i.instructor_name;
SELECT course_id, COUNT(*) AS completions
FROM enrollments
WHERE completion_status = TRUE
GROUP BY course_id
HAVING COUNT(*) > 20;
SELECT u.user_id, u.user_name, c.course_id, c.title
FROM users u
INNER JOIN enrollments e ON u.user_id = e.user_id
INNER JOIN courses c ON e.course_id = c.course_id;
SELECT c.course_id, c.title, e.enrollment_id
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;
SELECT 
    e1.user_id AS user1_id, u1.user_name AS user1_name,
    e2.user_id AS user2_id, u2.user_name AS user2_name,
    e1.course_id
FROM enrollments e1
JOIN enrollments e2 ON e1.course_id = e2.course_id AND e1.user_id <> e2.user_id
JOIN users u1 ON e1.user_id = u1.user_id
JOIN users u2 ON e2.user_id = u2.user_id
WHERE e1.completion_status = TRUE AND e2.completion_status = TRUE
ORDER BY e1.course_id;
