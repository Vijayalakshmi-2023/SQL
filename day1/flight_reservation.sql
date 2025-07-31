CREATE DATABASE airline_db;
USE airline_db;
CREATE TABLE airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    departure_airport_id INT,
    arrival_airport_id INT,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    FOREIGN KEY (departure_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (arrival_airport_id) REFERENCES airports(airport_id)
);
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT,
    flight_id INT,
    booking_date DATETIME NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);
INSERT INTO airports (airport_name, city, country) VALUES
('JFK Airport', 'New York', 'USA'),
('LAX Airport', 'Los Angeles', 'USA'),
('Heathrow Airport', 'London', 'UK'),
('Changi Airport', 'Singapore', 'Singapore');
INSERT INTO flights (flight_number, departure_airport_id, arrival_airport_id, departure_time, arrival_time) VALUES
('AA101', 1, 2, '2023-08-01 08:00:00', '2023-08-01 11:00:00'),
('BA202', 2, 3, '2023-08-02 14:00:00', '2023-08-02 22:00:00'),
('SG301', 3, 4, '2023-08-03 07:30:00', '2023-08-03 15:30:00'),
('UA404', 1, 4, '2023-08-04 09:00:00', '2023-08-04 17:00:00'),
('DL505', 4, 1, '2023-08-05 12:00:00', '2023-08-05 18:00:00');
INSERT INTO passengers (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@example.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@example.com', '123-456-7897'),
('Ivy', 'King', 'ivy.king@example.com', '123-456-7898'),
('Jack', 'Lee', 'jack.lee@example.com', '123-456-7899');
INSERT INTO bookings (passenger_id, flight_id, booking_date) VALUES
(1, 1, '2023-07-01 10:00:00'),
(2, 2, '2023-07-02 14:30:00'),
(3, 3, '2023-07-03 09:00:00'),
(4, 4, '2023-07-04 11:15:00'),
(5, 5, '2023-07-05 13:45:00'),
(6, 1, '2023-07-06 08:30:00'),
(7, 2, '2023-07-07 16:00:00'),
(8, 3, '2023-07-08 18:30:00'),
(9, 4, '2023-07-09 10:30:00'),
(10, 5, '2023-07-10 12:00:00');
SELECT f.flight_number, f.departure_time, f.arrival_time, a1.airport_name AS departure_airport, a2.airport_name AS arrival_airport
FROM flights f
JOIN airports a1 ON f.departure_airport_id = a1.airport_id
JOIN airports a2 ON f.arrival_airport_id = a2.airport_id
WHERE f.departure_airport_id = 1 AND f.arrival_airport_id = 2;
SELECT p.first_name, p.last_name, p.email, p.phone_number
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
WHERE b.flight_id = 1;
