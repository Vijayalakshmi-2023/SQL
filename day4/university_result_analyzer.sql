SELECT s.student_id, s.name, r.score
FROM students s
JOIN results r ON s.student_id = r.student_id
WHERE r.score > (
    SELECT AVG(score)
    FROM results
    WHERE subject_id = r.subject_id
      AND exam_type = r.exam_type
);
SELECT sub.subject_id, subj.subject_name, ROUND(sub.avg_score, 2) AS average_score
FROM (
    SELECT subject_id, AVG(score) AS avg_score
    FROM results
    GROUP BY subject_id
) AS sub
JOIN subjects subj ON sub.subject_id = subj.subject_id;
SELECT student_id, subject_id, exam_type, score
FROM results
WHERE exam_type = 'midterm'

UNION ALL

SELECT student_id, subject_id, exam_type, score
FROM results
WHERE exam_type = 'final';
SELECT 
    r.student_id,
    s.name,
    r.subject_id,
    r.exam_type,
    r.score,
    CASE 
        WHEN r.score >= 85 THEN 'A'
        WHEN r.score >= 70 THEN 'B'
        WHEN r.score >= 50 THEN 'C'
        ELSE 'F'
    END AS grade
FROM results r
JOIN students s ON r.student_id = s.student_id;
SELECT 
    c.course_level,
    subj.subject_name,
    COUNT(DISTINCT r.student_id) AS num_students,
    ROUND(AVG(r.score), 2) AS avg_score
FROM results r
JOIN students s ON r.student_id = s.student_id
JOIN subjects subj ON r.subject_id = subj.subject_id
JOIN courses c ON s.course_id = c.course_id
GROUP BY c.course_level, subj.subject_name;
SELECT student_id, name, enrollment_date
FROM students
WHERE enrollment_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
