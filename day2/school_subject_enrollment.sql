CREATE TABLE subject_enrollments (
    enroll_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    subject VARCHAR(50),
    grade INT,
    status VARCHAR(20)
);
SELECT *
FROM subject_enrollments
WHERE grade >= 80 AND subject IN ('Math', 'English');
SELECT *
FROM subject_enrollments
WHERE student_name LIKE '%an%';
SELECT *
FROM subject_enrollments
WHERE status IS NULL;
SELECT DISTINCT subject
FROM subject_enrollments;
SELECT *
FROM subject_enrollments
ORDER BY grade DESC;
