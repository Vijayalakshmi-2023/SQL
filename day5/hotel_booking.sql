-- Guests table to store guest details
CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,  -- Ensure phone is unique
    email VARCHAR(100),
    address VARCHAR(255)
);

-- Rooms table to store room details
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,  -- Unique room numbers
    room_type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,  -- Maximum number of people the room can accommodate
    status VARCHAR(20) CHECK (status IN ('available', 'booked', 'maintenance')) NOT NULL  -- Room status
);

-- Bookings table to store booking details
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    number_of_guests INT NOT NULL CHECK (number_of_guests <= (SELECT capacity FROM rooms WHERE room_id = bookings.room_id)),  -- Check number of guests against room capacity
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    status VARCHAR(20) CHECK (status IN ('confirmed', 'canceled')) DEFAULT 'confirmed'
);

-- Payments table to store payment details
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) CHECK (payment_status IN ('successful', 'failed')) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);
-- Update room status to 'booked' upon check-in
UPDATE rooms
SET status = 'booked'
WHERE room_id = ?;

-- Update room status to 'available' upon check-out
UPDATE rooms
SET status = 'available'
WHERE room_id = ?;
-- Delete booking and associated payment(s) will be deleted automatically
DELETE FROM bookings
WHERE booking_id = ?;
-- Add constraint for minimum stay duration (2 days)
ALTER TABLE bookings
ADD CONSTRAINT chk_minimum_stay_duration CHECK (DATEDIFF(check_out, check_in) >= 2);

-- To modify or drop the constraint
ALTER TABLE bookings
DROP CONSTRAINT chk_minimum_stay_duration;
-- Start a transaction
DELIMITER $$

CREATE PROCEDURE book_and_pay(IN guest_id INT, IN room_id INT, IN check_in DATE, IN check_out DATE, IN num_guests INT, IN payment_amount DECIMAL(10,2))
BEGIN
    DECLARE booking_id INT;

    -- Start a transaction
    START TRANSACTION;

    -- Insert booking
    INSERT INTO bookings (guest_id, room_id, check_in, check_out, number_of_guests, status)
    VALUES (guest_id, room_id, check_in, check_out, num_guests, 'confirmed');

    -- Get the last inserted booking_id
    SET booking_id = LAST_INSERT_ID();

    -- Insert payment
    INSERT INTO payments (booking_id, amount, payment_status)
    VALUES (booking_id, payment_amount, 'successful');

    -- Check if payment was successful
    IF (SELECT payment_status FROM payments WHERE booking_id = booking_id ORDER BY payment_date DESC LIMIT 1) = 'successful' THEN
        -- Commit if payment is successful
        COMMIT;
    ELSE
        -- Rollback if payment failed
        ROLLBACK;
    END IF;
    
END$$

DELIMITER ;

-- Insert guest details
INSERT INTO guests (first_name, last_name, phone, email, address)
VALUES ('John', 'Doe', '1234567890', 'john.doe@example.com', '123 Elm Street');

-- Insert room details
INSERT INTO rooms (room_number, room_type, capacity, status)
VALUES ('101', 'Single', 2, 'available');

-- Make a booking and payment (wrap in transaction)
START TRANSACTION;

INSERT INTO bookings (guest_id, room_id, check_in, check_out, number_of_guests)
VALUES (1, 1, '2025-08-15', '2025-08-18', 2);

SET @last_booking_id = LAST_INSERT_ID();

INSERT INTO payments (booking_id, amount, payment_status)
VALUES (@last_booking_id, 200.00, 'successful');

COMMIT;
