CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(255),
    contact_number VARCHAR(15),
    email VARCHAR(255),
    registration_date TIMESTAMP
);
CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    session_name VARCHAR(255),
    session_date TIMESTAMP,
    trainer_id INT  -- References trainer who is conducting the session
);
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    member_id INT,
    session_id INT,
    attendance_date TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);
CREATE VIEW view_attendance_summary AS
SELECT 
    m.member_id, 
    m.name AS member_name,
    s.session_name,
    a.attendance_date
FROM attendance a
JOIN members m ON a.member_id = m.member_id
JOIN sessions s ON a.session_id = s.session_id;
DELIMITER $$

CREATE PROCEDURE log_attendance(
    IN member_id INT, 
    IN session_id INT
)
BEGIN
    -- Insert attendance record
    INSERT INTO attendance (member_id, session_id, attendance_date)
    VALUES (member_id, session_id, NOW());
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION get_monthly_visits(member_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE visit_count INT;

    -- Count the number of sessions attended by the member this month
    SELECT COUNT(*) INTO visit_count
    FROM attendance
    WHERE member_id = member_id
    AND MONTH(attendance_date) = MONTH(CURRENT_DATE())
    AND YEAR(attendance_date) = YEAR(CURRENT_DATE());
    
    RETURN visit_count;
END$$

DELIMITER ;
CREATE TABLE member_points (
    member_id INT PRIMARY KEY,
    points INT DEFAULT 0,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);
DELIMITER $$

CREATE TRIGGER after_attendance
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
    DECLARE current_points INT;

    -- Check if the member already has points
    SELECT points INTO current_points
    FROM member_points
    WHERE member_id = NEW.member_id;

    -- If points exist, update; otherwise, insert new entry
    IF current_points IS NOT NULL THEN
        UPDATE member_points
        SET points = points + 10  -- Award 10 points for attending a session
        WHERE member_id = NEW.member_id;
    ELSE
        INSERT INTO member_points (member_id, points)
        VALUES (NEW.member_id, 10);  -- Award 10 points for first attendance
    END IF;
END$$

DELIMITER ;
CREATE VIEW view_active_members AS
SELECT DISTINCT 
    m.member_id, 
    m.name AS member_name
FROM members m
JOIN attendance a ON m.member_id = a.member_id
WHERE a.attendance_date >= CURDATE() - INTERVAL 30 DAY;
