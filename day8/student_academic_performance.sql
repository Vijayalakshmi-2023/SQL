CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100)
);
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    prerequisite_course_id INT NULL,  -- self-referencing foreign key for prerequisites
    FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(course_id)
);
CREATE TABLE Grades (
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    marks DECIMAL(5, 2),
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
SELECT
    g.student_id,
    s.student_name,
    c.course_name,
    g.semester,
    g.marks
FROM Grades g
JOIN Students s ON g.student_id = s.student_id
JOIN Courses c ON g.course_id = c.course_id
ORDER BY g.student_id, g.semester, c.course_name;
WITH RankedGrades AS (
    SELECT
        g.student_id,
        s.student_name,
        c.course_name,
        g.semester,
        g.marks,
        RANK() OVER (PARTITION BY c.course_id, g.semester ORDER BY g.marks DESC) AS rank_in_subject
    FROM Grades g
    JOIN Students s ON g.student_id = s.student_id
    JOIN Courses c ON g.course_id = c.course_id
)
SELECT * FROM RankedGrades
WHERE rank_in_subject = 1;  -- Only the toppers
WITH ExamAttempts AS (
    SELECT
        g.student_id,
        s.student_name,
        c.course_name,
        g.semester,
        g.marks,
        ROW_NUMBER() OVER (PARTITION BY g.student_id, c.course_id ORDER BY g.semester) AS attempt_order
    FROM Grades g
    JOIN Students s ON g.student_id = s.student_id
    JOIN Courses c ON g.course_id = c.course_id
)
SELECT * FROM ExamAttempts
ORDER BY student_id, course_name, attempt_order;
WITH MarksComparison AS (
    SELECT
        g.student_id,
        s.student_name,
        c.course_name,
        g.semester,
        g.marks,
        LAG(g.marks) OVER (PARTITION BY g.student_id, c.course_id ORDER BY g.semester) AS previous_semester_marks,
        LEAD(g.marks) OVER (PARTITION BY g.student_id, c.course_id ORDER BY g.semester) AS next_semester_marks
    FROM Grades g
    JOIN Students s ON g.student_id = s.student_id
    JOIN Courses c ON g.course_id = c.course_id
)
SELECT * FROM MarksComparison
ORDER BY student_id, course_name, semester;
WITH SubjectWisePerformance AS (
    SELECT
        g.student_id,
        s.student_name,
        c.course_name,
        AVG(g.marks) AS average_marks
    FROM Grades g
    JOIN Students s ON g.student_id = s.student_id
    JOIN Courses c ON g.course_id = c.course_id
    GROUP BY g.student_id, s.student_name, c.course_name
)
SELECT * FROM SubjectWisePerformance
ORDER BY course_name, average_marks DESC;
WITH SemesterWisePerformance AS (
    SELECT
        g.student_id,
        s.student_name,
        g.semester,
        AVG(g.marks) AS average_marks
    FROM Grades g
    JOIN Students s ON g.student_id = s.student_id
    GROUP BY g.student_id, s.student_name, g.semester
)
SELECT * FROM SemesterWisePerformance
ORDER BY semester, average_marks DESC;
WITH RECURSIVE CoursePrerequisites AS (
    -- Base case: Initial course
    SELECT
        course_id,
        course_name,
        prerequisite_course_id
    FROM Courses
    WHERE prerequisite_course_id IS NULL  -- Starting with courses that have no prerequisites
    
    UNION ALL
    
    -- Recursive case: Courses that depend on the previous ones
    SELECT
        c.course_id,
        c.course_name,
        c.prerequisite_course_id
    FROM Courses c
    JOIN CoursePrerequisites cp ON c.prerequisite_course_id = cp.course_id
)
SELECT * FROM CoursePrerequisites
ORDER BY course_name;
-- Toppers in each subject
SELECT * FROM RankedGrades WHERE rank_in_subject = 1;

-- Student exam attempts order
SELECT * FROM ExamAttempts;

-- Comparing marks between semesters
SELECT * FROM MarksComparison;

-- Subject-wise average performance
SELECT * FROM SubjectWisePerformance;

-- Recursive CTE for course prerequisites
SELECT * FROM CoursePrerequisites;
