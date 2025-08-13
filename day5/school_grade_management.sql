-- Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique student ID
    first_name VARCHAR(100) NOT NULL,            -- First name of the student
    last_name VARCHAR(100) NOT NULL,             -- Last name of the student
    email VARCHAR(100) UNIQUE,                   -- Email of the student (must be unique)
    date_of_birth DATE,                          -- Date of birth
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp when the student is added
);

-- Subjects Table
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique subject ID
    subject_name VARCHAR(100) NOT NULL,         -- Name of the subject (NOT NULL)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp when the subject is added
);

-- Grades Table
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,    -- Unique grade ID
    student_id INT,                             -- Foreign Key: References students
    subject_id INT,                             -- Foreign Key: References subjects
    grade INT CHECK (grade BETWEEN 0 AND 100),  -- Grade is between 0 and 100
    retest BOOLEAN DEFAULT FALSE,               -- Indicates if this is from a retest
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the grade was last updated
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,  -- Foreign Key to students
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE   -- Foreign Key to subjects
);
-- Modify the grade scale to allow values between 0 and 150

ALTER TABLE grades
    ADD CONSTRAINT grade_check CHECK (grade BETWEEN 0 AND 150);
-- Insert a new grade for a student (student_id = 1, subject_id = 1) with grade 85
INSERT INTO grades (student_id, subject_id, grade)
VALUES (1, 1, 85);
UPDATE grades
SET grade = 90, retest = TRUE, updated_at = CURRENT_TIMESTAMP
WHERE student_id = 1 AND subject_id = 1;
DELETE FROM grades
WHERE student_id = 1 AND grade < 50;
START TRANSACTION;

-- Insert or update grades for multiple students

-- Student 1 in subject 1
INSERT INTO grades (student_id, subject_id, grade)
VALUES (1, 1, 75)
ON DUPLICATE KEY UPDATE grade = VALUES(grade);

-- Student 2 in subject 2
INSERT INTO grades (student_id, subject_id, grade)
VALUES (2, 2, 88)
ON DUPLICATE KEY UPDATE grade = VALUES(grade);
-- Insert students
INSERT INTO students (first_name, last_name, email, date_of_birth)
VALUES ('John', 'Doe', 'john.doe@example.com', '2000-01-01'),
       ('Jane', 'Smith', 'jane.smith@example.com', '1999-06-15');
-- Insert subjects
INSERT INTO subjects (subject_name)
VALUES ('Math'),
       ('Science'),
       ('History');
-- Insert grades for students
INSERT INTO grades (student_id, subject_id, grade)
VALUES (1, 1, 85),   -- John Doe gets 85 in Math
       (2, 2, 90);   -- Jane Smith gets 90 in Science
-- Delete failing grades for student 1
DELETE FROM grades
WHERE student_id = 1 AND grade < 50;
