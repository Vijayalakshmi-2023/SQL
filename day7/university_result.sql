CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255),
    enrollment_number VARCHAR(100)
);
CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(255)
);
CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    marks INT,
    evaluator_id INT,  -- Hiding this information in the view
    locked BOOLEAN DEFAULT FALSE,  -- Prevents updates if locked
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);
CREATE VIEW view_student_grades AS
SELECT 
    g.student_id, 
    s.student_name,
    sub.subject_name, 
    g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id;
CREATE TABLE grade_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    old_marks INT,
    new_marks INT,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,  -- ID of the user who performed the update (e.g., admin)
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);
DELIMITER $$

CREATE PROCEDURE update_grade(
    IN student_id INT, 
    IN subject_id INT, 
    IN new_marks INT, 
    IN updated_by INT
)
BEGIN
    DECLARE old_marks INT;
    
    -- Get the current marks before updating
    SELECT marks INTO old_marks
    FROM grades
    WHERE student_id = student_id AND subject_id = subject_id;
    
    -- Update the grade
    UPDATE grades
    SET marks = new_marks
    WHERE student_id = student_id AND subject_id = subject_id;
    
    -- Insert into the audit log
    INSERT INTO grade_audit (student_id, subject_id, old_marks, new_marks, updated_by)
    VALUES (student_id, subject_id, old_marks, new_marks, updated_by);
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION calculate_gpa(student_id INT)
RETURNS DECIMAL(3, 2)
DETERMINISTIC
BEGIN
    DECLARE total_marks INT DEFAULT 0;
    DECLARE total_subjects INT DEFAULT 0;
    DECLARE gpa DECIMAL(3, 2);
    
    -- Calculate total marks and number of subjects
    SELECT SUM(marks), COUNT(subject_id) 
    INTO total_marks, total_subjects
    FROM grades
    WHERE student_id = student_id;
    
    -- Calculate GPA (assuming 100 marks = 4 GPA)
    SET gpa = (total_marks / total_subjects) / 25;  -- (100 marks = 4 GPA)
    
    RETURN gpa;
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER before_update_grades
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    -- Prevent update if grade is locked
    IF OLD.locked = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Grade update is locked for this subject.';
    END IF;
END$$

DELIMITER ;
CREATE VIEW view_final_results AS
SELECT 
    g.student_id, 
    s.student_name,
    sub.subject_name, 
    g.marks
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id
WHERE g.locked = TRUE;  -- Only show locked final results
