-- Airlines Table
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL
);

-- Airports Table
CREATE TABLE airports (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_code VARCHAR(10) UNIQUE NOT NULL,
    airport_name VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL
);

-- Flights Table
CREATE TABLE flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(20) NOT NULL,
    airline_id INT,
    departure_airport_id INT,
    arrival_airport_id INT,
    flight_date DATETIME,
    flight_duration TIME,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (departure_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport_id) REFERENCES airports(airport_id)
);

-- Passengers Table
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);

-- Bookings Table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    flight_id INT,
    booking_date DATETIME,
    status ENUM('confirmed', 'cancelled', 'pending') NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);
-- Index on flight_date for quick lookups by date
CREATE INDEX idx_flight_date ON flights(flight_date);

-- Index on departure_airport_id for fast filtering by airport
CREATE INDEX idx_departure_airport ON flights(departure_airport_id);

-- Index on passenger_id for quick access to bookings by passenger
CREATE INDEX idx_passenger_id ON bookings(passenger_id);
EXPLAIN
SELECT f.flight_number, f.flight_date, a1.airport_name AS departure_airport, a2.airport_name AS arrival_airport
FROM flights f
JOIN airports a1 ON f.departure_airport_id = a1.airport_id
JOIN airports a2 ON f.arrival_airport_id = a2.airport_id
WHERE a1.city = 'New York' AND f.flight_date BETWEEN '2025-08-01' AND '2025-08-31'
ORDER BY f.flight_date;
SELECT p.first_name, p.last_name, COUNT(b.booking_id) AS num_flights
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id
HAVING num_flights = (
    SELECT MAX(num_flights)
    FROM (
        SELECT COUNT(b.booking_id) AS num_flights
        FROM bookings b
        GROUP BY b.passenger_id
    ) AS subquery
)
ORDER BY num_flights DESC;
-- Denormalized Table for Frequent Flyer Reporting
CREATE TABLE frequent_flyers (
    passenger_id INT PRIMARY KEY,
    num_flights INT,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- Insert data into frequent flyer table (example)
INSERT INTO frequent_flyers (passenger_id, num_flights)
SELECT p.passenger_id, COUNT(b.booking_id)
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
GROUP BY p.passenger_id;
SELECT f.flight_number, f.flight_date, a1.airport_name AS departure_airport, a2.airport_name AS arrival_airport
FROM flights f
JOIN airports a1 ON f.departure_airport_id = a1.airport_id
JOIN airports a2 ON f.arrival_airport_id = a2.airport_id
WHERE f.flight_date > NOW()
ORDER BY f.flight_date
LIMIT 5;
