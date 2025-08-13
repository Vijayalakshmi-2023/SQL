CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(255),
    course_type VARCHAR(50) -- 'Required' or 'Elective'
);
CREATE TABLE Prerequisites (
    course_id INT,
    prerequisite_course_id INT,
    PRIMARY KEY (course_id, prerequisite_course_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(course_id)
);
CREATE TABLE Student_Courses (
    student_id INT,
    course_id INT,
    completion_status VARCHAR(50), -- 'Completed', 'In Progress'
    completion_date TIMESTAMP,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
WITH RECURSIVE CoursePaths AS (
    -- Base case: Start with the courses that have no prerequisites
    SELECT 
        c.course_id, 
        c.course_name, 
        NULL AS prerequisite_course_id,
        1 AS level
    FROM Courses c
    WHERE c.course_id NOT IN (SELECT prerequisite_course_id FROM Prerequisites)
    
    UNION ALL
    
    -- Recursive case: Include courses that depend on previously found courses
    SELECT 
        c.course_id, 
        c.course_name, 
        p.prerequisite_course_id,
        cp.level + 1 AS level
    FROM Prerequisites p
    JOIN Courses c ON p.course_id = c.course_id
    JOIN CoursePaths cp ON p.prerequisite_course_id = cp.course_id
)
SELECT 
    course_id, 
    course_name, 
    prerequisite_course_id, 
    level
FROM CoursePaths
ORDER BY level, course_id;
WITH RankedCourses AS (
    SELECT
        c.course_id,
        c.course_name,
        c.course_type,
        RANK() OVER (ORDER BY CASE WHEN c.course_type = 'Required' THEN 1 ELSE 2 END) AS rank
    FROM Courses c
)
SELECT 
    course_id,
    course_name,
    course_type,
    rank
FROM RankedCourses
ORDER BY rank, course_id;
WITH StudentCourseProgress AS (
    SELECT
        sc.student_id,
        sc.course_id,
        sc.completion_status,
        sc.completion_date,
        LEAD(sc.course_id) OVER (PARTITION BY sc.student_id ORDER BY sc.completion_date) AS next_course_id
    FROM Student_Courses sc
    WHERE sc.completion_status = 'Completed'
)
SELECT 
    student_id, 
    course_id, 
    completion_status, 
    completion_date, 
    next_course_id
FROM StudentCourseProgress
ORDER BY student_id, completion_date;
WITH StudentCourseProgress AS (
    SELECT
        sc.student_id,
        sc.course_id,
        sc.completion_status,
        sc.completion_date,
        LEAD(sc.course_id) OVER (PARTITION BY sc.student_id ORDER BY sc.completion_date) AS next_course_id,
        RANK() OVER (PARTITION BY sc.student_id ORDER BY sc.completion_date) AS course_rank
    FROM Student_Courses sc
)
SELECT 
    scp.student_id, 
    c.course_name, 
    scp.completion_status, 
    scp.completion_date, 
    c2.course_name AS next_course_suggestion
FROM StudentCourseProgress scp
JOIN Courses c ON scp.course_id = c.course_id
LEFT JOIN Courses c2 ON scp.next_course_id = c2.course_id
ORDER BY scp.student_id, scp.course_rank;

