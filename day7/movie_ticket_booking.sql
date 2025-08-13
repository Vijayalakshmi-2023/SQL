CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    movie_title VARCHAR(255),
    movie_duration INT  -- in minutes
);
CREATE TABLE shows (
    show_id INT PRIMARY KEY,
    movie_id INT,
    show_time TIMESTAMP,
    total_seats INT,
    available_seats INT,  -- Number of seats available for booking
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    show_id INT,
    customer_id INT,
    seat_count INT,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (show_id) REFERENCES shows(show_id)
);
CREATE VIEW view_now_showing AS
SELECT 
    s.show_id, 
    m.movie_title, 
    s.show_time, 
    s.available_seats
FROM shows s
JOIN movies m ON s.movie_id = m.movie_id
WHERE s.show_time >= CURRENT_TIMESTAMP;  -- Shows only upcoming shows
DELIMITER $$

CREATE PROCEDURE book_ticket(
    IN show_id INT, 
    IN customer_id INT, 
    IN seat_count INT
)
BEGIN
    DECLARE available_seats INT;

    -- Get the current available seats for the show
    SELECT available_seats INTO available_seats
    FROM shows
    WHERE show_id = show_id;

    -- Check if enough seats are available
    IF available_seats >= seat_count THEN
        -- Insert booking record
        INSERT INTO bookings (show_id, customer_id, seat_count)
        VALUES (show_id, customer_id, seat_count);
        
        -- Update available seats for the show
        UPDATE shows
        SET available_seats = available_seats - seat_count
        WHERE show_id = show_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough seats available';
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION get_available_seats(show_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE available_seats INT;

    -- Retrieve the number of available seats for the given show
    SELECT available_seats INTO available_seats
    FROM shows
    WHERE show_id = show_id;

    RETURN available_seats;
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER before_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE available_seats INT;

    -- Get the available seats for the selected show
    SELECT available_seats INTO available_seats
    FROM shows
    WHERE show_id = NEW.show_id;

    -- If there are no available seats, prevent the booking
    IF available_seats = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The show is houseful. No seats available.';
    END IF;
END$$

DELIMITER ;
CREATE VIEW view_public_bookings AS
SELECT 
    b.booking_id, 
    m.movie_title, 
    s.show_time, 
    b.seat_count
FROM bookings b
JOIN shows s ON b.show_id = s.show_id
JOIN movies m ON s.movie_id = m.movie_id;
