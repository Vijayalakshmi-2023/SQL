CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(200),
    category VARCHAR(50),
    duration INT,             -- assuming duration is in hours
    price DECIMAL(10,2),
    instructor VARCHAR(100),
    status VARCHAR(20)        -- e.g., 'Active', 'Inactive'
);
SELECT title, category, price
FROM courses
WHERE status = 'Active' AND price < 1000;
SELECT DISTINCT instructor
FROM courses;
SELECT *
FROM courses
WHERE title LIKE 'Data%';
SELECT *
FROM courses
WHERE category IN ('Tech', 'Business');
SELECT *
FROM courses
WHERE instructor IS NULL;
SELECT *
FROM courses
ORDER BY price DESC, duration ASC;
