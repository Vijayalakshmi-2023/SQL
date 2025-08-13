-- Assuming students and courses are already present
INSERT INTO enrollments (student_id, course_id, grade)
VALUES 
    (1, 101, 85),   -- Student 1 enrolls in Course 101 with grade 85
    (2, 102, 92);   -- Student 2 enrolls in Course 102 with grade 92
UPDATE courses
SET available_slots = available_slots - 1
WHERE course_id IN (SELECT DISTINCT course_id FROM enrollments);
-- Assuming student_id = 1 needs to be deleted
DELETE FROM students WHERE student_id = 1;
ALTER TABLE enrollments
ADD CONSTRAINT grade_check CHECK (grade >= 0 AND grade <= 100);
ALTER TABLE enrollments
DROP CONSTRAINT grade_check;
ALTER TABLE enrollments
ADD CONSTRAINT grade_check CHECK (grade >= 0 AND grade <= 200);
-- Start Transaction
BEGIN;

-- Bulk Enrollment
INSERT INTO enrollments (student_id, course_id, grade) 
VALUES 
    (3, 101, 90),
    (4, 102, 75),
    (5, 103, 88);

-- Update Course Availability
UPDATE courses
SET available_slots = available_slots - 1
WHERE course_id IN (SELECT DISTINCT course_id FROM enrollments WHERE student_id IN (3, 4, 5));

-- If everything goes well, commit the transaction
COMMIT;

-- If there's an error, rollback the transaction
-- ROLLBACK;
BEGIN;

-- First part: Update course availability based on enrollments
UPDATE courses
SET available_slots = available_slots - 1
WHERE course_id = 101;

-- Second part: Insert new enrollments
INSERT INTO enrollments (student_id, course_id, grade) 
VALUES (6, 101, 80);

-- Ensure consistency by committing both steps together
COMMIT;
