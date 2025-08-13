CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(100),
    room_rate DECIMAL(10, 2),
    is_available BOOLEAN DEFAULT TRUE
);
CREATE TABLE maintenance_schedules (
    schedule_id INT PRIMARY KEY,
    room_id INT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    room_id INT,
    customer_id INT,
    check_in_date TIMESTAMP,
    check_out_date TIMESTAMP,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);
CREATE VIEW view_available_rooms AS
SELECT 
    r.room_id, 
    r.room_type, 
    r.room_rate
FROM rooms r
WHERE r.is_available = TRUE
AND NOT EXISTS (
    SELECT 1
    FROM maintenance_schedules m
    WHERE m.room_id = r.room_id
    AND (m.start_date <= CURRENT_DATE AND m.end_date >= CURRENT_DATE)
);
DELIMITER $$

CREATE PROCEDURE book_room(
    IN customer_id INT, 
    IN room_id INT, 
    IN check_in_date TIMESTAMP, 
    IN check_out_date TIMESTAMP
)
BEGIN
    DECLARE room_rate DECIMAL(10, 2);
    
    -- Check if the room is available
    IF EXISTS (
        SELECT 1
        FROM rooms 
        WHERE room_id = room_id AND is_available = TRUE
    ) THEN
        -- Get room rate
        SELECT room_rate INTO room_rate
        FROM rooms
        WHERE room_id = room_id;
        
        -- Insert into bookings table
        INSERT INTO bookings (room_id, customer_id, check_in_date, check_out_date)
        VALUES (room_id, customer_id, check_in_date, check_out_date);
        
        -- Update room availability
        UPDATE rooms
        SET is_available = FALSE
        WHERE room_id = room_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is not available for booking';
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION calculate_stay_cost(
    room_id INT, 
    check_in_date TIMESTAMP, 
    check_out_date TIMESTAMP
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE room_rate DECIMAL(10, 2);
    DECLARE stay_duration INT;
    DECLARE total_cost DECIMAL(10, 2);
    
    -- Get the room rate
    SELECT room_rate INTO room_rate
    FROM rooms
    WHERE room_id = room_id;

    -- Calculate stay duration in days
    SET stay_duration = DATEDIFF(check_out_date, check_in_date);

    -- Calculate total cost
    SET total_cost = room_rate * stay_duration;

    RETURN total_cost;
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    -- Update the room availability after booking
    UPDATE rooms
    SET is_available = FALSE
    WHERE room_id = NEW.room_id;
END$$

DELIMITER ;
CREATE VIEW view_receptionist_access AS
SELECT 
    b.booking_id, 
    m.name AS customer_name, 
    r.room_type, 
    b.check_in_date, 
    b.check_out_date
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
JOIN members m ON b.customer_id = m.member_id;
