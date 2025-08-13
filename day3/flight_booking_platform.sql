CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(100)
);

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    airline_id INT,
    origin VARCHAR(100),
    destination VARCHAR(100),
    total_seats INT,
    flight_date DATE,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    seat_number VARCHAR(10),
    booking_date DATE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);
SELECT 
    a.airline_id,
    a.airline_name,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
JOIN airlines a ON f.airline_id = a.airline_id
GROUP BY a.airline_id, a.airline_name;
SELECT 
    p.passenger_id,
    p.passenger_name,
    COUNT(b.booking_id) AS flights_taken
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
GROUP BY p.passenger_id, p.passenger_name
ORDER BY flights_taken DESC;
SELECT 
    f.flight_id,
    f.origin,
    f.destination,
    COUNT(b.booking_id) * 100.0 / f.total_seats AS occupancy_rate
FROM flights f
JOIN bookings b ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.origin, f.destination, f.total_seats
HAVING COUNT(b.booking_id) * 100.0 / f.total_seats > 80;
SELECT 
    b.booking_id,
    f.flight_id,
    f.origin,
    f.destination,
    p.passenger_name,
    b.booking_date
FROM bookings b
INNER JOIN flights f ON b.flight_id = f.flight_id
INNER JOIN passengers p ON b.pass;
SELECT 
    a.airline_id,
    a.airline_name,
    f.flight_id,
    f.origin,
    f.destination
FROM flights f
LEFT JOIN airlines a ON f.airline_id = a.airline_id;
SELECT 
    p1.passenger_name AS passenger1,
    p2.passenger_name AS passenger2,
    f1.origin,
    f1.destination
FROM bookings b1
JOIN bookings b2 ON b1.flight_id = b2.flight_id AND b1.passenger_id <> b2.passenger_id
JOIN flights f1 ON b1.flight_id = f1.flight_id
JOIN passengers p1 ON b1.passenger_id = p1.passenger_id
JOIN passengers p2 ON b2.passenger_id = p2.passenger_id
GROUP BY p1.passenger_name, p2.passenger_name, f1.origin, f1.destination;

