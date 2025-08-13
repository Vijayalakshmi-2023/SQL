CREATE TABLE fact_scores (
    score_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    exam_id INT,
    semester_id INT,
    score DECIMAL(5, 2),  -- Score as percentage or grade equivalent
    FOREIGN KEY (student_id) REFERENCES dim_student(student_id),
    FOREIGN KEY (subject_id) REFERENCES dim_subject(subject_id),
    FOREIGN KEY (exam_id) REFERENCES dim_exam(exam_id),
    FOREIGN KEY (semester_id) REFERENCES dim_time(semester_id)
);
CREATE TABLE dim_student (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    department_id INT,
    batch_id INT,
    enrollment_year INT
);
CREATE TABLE dim_subject (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(255),
    department_id INT,
    level VARCHAR(50)  -- Undergrad, Postgrad
);
CREATE TABLE dim_exam (
    exam_id INT PRIMARY KEY,
    exam_name VARCHAR(255),
    exam_date DATE
);
CREATE TABLE dim_time (
    semester_id INT PRIMARY KEY,
    semester_name VARCHAR(255),
    year INT,
    quarter INT  -- Can be used for term-based reporting
);
-- Step 1: Extract data from OLTP tables
WITH raw_grades AS (
    SELECT
        s.student_id,
        g.subject_id,
        g.exam_id,
        g.semester_id,
        g.grade
    FROM grades g
    JOIN students s ON g.student_id = s.student_id
)
-- Step 2: Transform data (convert letter grades to percentage scores)
, transformed_grades AS (
    SELECT 
        student_id,
        subject_id,
        exam_id,
        semester_id,
        CASE
            WHEN grade = 'A' THEN 90
            WHEN grade = 'B' THEN 80
            WHEN grade = 'C' THEN 70
            WHEN grade = 'D' THEN 60
            WHEN grade = 'F' THEN 0
            ELSE NULL
        END AS score
    FROM raw_grades
)
-- Step 3: Load data into fact_scores
INSERT INTO fact_scores (student_id, subject_id, exam_id, semester_id, score)
SELECT 
    student_id,
    subject_id,
    exam_id,
    semester_id,
    score
FROM transformed_grades;
SELECT 
    t.semester_name,
    AVG(f.score) AS avg_score
FROM fact_scores f
JOIN dim_time t ON f.semester_id = t.semester_id
GROUP BY t.semester_name
ORDER BY t.year, t.quarter;
SELECT 
    sub.subject_name,
    COUNT(CASE WHEN f.score < 50 THEN 1 END) AS failed_students,
    COUNT(f.score) AS total_students,
    ROUND(COUNT(CASE WHEN f.score < 50 THEN 1 END) * 100.0 / COUNT(f.score), 2) AS failure_rate
FROM fact_scores f
JOIN dim_subject sub ON f.subject_id = sub.subject_id
GROUP BY sub.subject_name
ORDER BY failure_rate DESC;
SELECT 
    sub.department_id,
    AVG(f.score) AS avg_score
FROM fact_scores f
JOIN dim_subject sub ON f.subject_id = sub.subject_id
GROUP BY sub.department_id
ORDER BY avg_score DESC;
SELECT 
    s.batch_id,
    AVG(f.score) AS avg_score
FROM fact_scores f
JOIN dim_student s ON f.student_id = s.student_id
GROUP BY s.batch_id
ORDER BY avg_score DESC;
SELECT 
    s.first_name,
    s.last_name,
    sub.subject_name,
    e.exam_name,
    g.grade
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id
JOIN exams e ON g.exam_id = e.exam_id
WHERE g.grade = 'F';  -- Find failing students
SELECT 
    t.semester_name,
    sub.department_id,
    AVG(f.score) AS avg_score
FROM fact_scores f
JOIN dim_time t ON f.semester_id = t.semester_id
JOIN dim_subject sub ON f.subject_id = sub.subject_id
GROUP BY t.semester_name, sub.department_id
ORDER BY t.semester_name, sub.department_id;
