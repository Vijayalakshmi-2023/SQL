-- Flights Table (Flight Information)
CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(100) NOT NULL,
    departure_airport VARCHAR(100) NOT NULL,
    arrival_airport VARCHAR(100) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    internal_notes TEXT,  -- Notes for internal use only (to be hidden)
    airline_id INT,  -- Foreign key to airlines
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

-- Passengers Table (Passenger Information)
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Bookings Table (Flight Bookings)
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    flight_id INT,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'booked',  -- Status of booking (booked, canceled, confirmed)
    pnr VARCHAR(6) UNIQUE,  -- Passenger Name Record
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- Airlines Table (Airline Information)
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(255) NOT NULL
);

-- Check-ins Table (Passenger Check-ins)
CREATE TABLE checkins (
    checkin_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    flight_id INT,
    checkin_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'checked_in',  -- Status of check-in (checked_in, not_checked_in)
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);
CREATE VIEW view_flight_schedule AS
SELECT
    flight_id,
    flight_number,
    departure_airport,
    arrival_airport,
    departure_time,
    arrival_time,
    airline_id  -- Internal notes are excluded
FROM flights;
DELIMITER $$

CREATE PROCEDURE book_flight(
    IN p_passenger_id INT,
    IN p_flight_id INT
)
BEGIN
    DECLARE v_pnr VARCHAR(6);

    -- Generate a 6-character PNR (alphanumeric)
    SET v_pnr = CONCAT(CHAR(FLOOR(65 + (RAND() * 26))), CHAR(FLOOR(65 + (RAND() * 26))), 
                       CHAR(FLOOR(65 + (RAND() * 26))), FLOOR(RAND() * 10), FLOOR(RAND() * 10), FLOOR(RAND() * 10));

    -- Insert booking record
    INSERT INTO bookings (passenger_id, flight_id, pnr)
    VALUES (p_passenger_id, p_flight_id, v_pnr);

    -- Return the PNR
    SELECT v_pnr AS PNR;
END $$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION get_passenger_count(flight_id INT)
RETURNS INT
BEGIN
    DECLARE v_count INT;

    -- Get the number of passengers booked for the specified flight
    SELECT COUNT(*) INTO v_count
    FROM bookings
    WHERE flight_id = flight_id;

    RETURN v_count;
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_checkin
AFTER INSERT ON checkins
FOR EACH ROW
BEGIN
    -- Update the status of the passenger to 'boarded' once checked in
    UPDATE bookings
    SET status = 'boarded'
    WHERE passenger_id = NEW.passenger_id AND flight_id = NEW.flight_id;
END $$

DELIMITER ;
CREATE VIEW customer_view_flight_schedule AS
SELECT
    flight_id,
    flight_number,
    departure_airport,
    arrival_airport,
    departure_time,
    arrival_time
FROM flights;
CREATE VIEW admin_view_flight_schedule AS
SELECT
    flight_id,
    flight_number,
    departure_airport,
    arrival_airport,
    departure_time,
    arrival_time,
    internal_notes  -- Admin view includes internal notes
FROM flights;
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' IDENTIFIED BY 'admin_password';
GRANT SELECT ON customer_view_flight_schedule TO 'customer_user'@'localhost' IDENTIFIED BY 'customer_password';
