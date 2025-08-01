CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20),
    origin VARCHAR(50),
    destination VARCHAR(50),
    status VARCHAR(20),
    departure_time DATETIME
);
SELECT flight_number, origin, destination
FROM flights
WHERE destination IN ('Chennai', 'Mumbai');
SELECT *
FROM flights
WHERE flight_number LIKE '%AI';
SELECT *
FROM flights
WHERE departure_time BETWEEN '2025-07-31 00:00:00' AND '2025-07-31 23:59:59';
SELECT *
FROM flights
WHERE status IS NULL;
SELECT DISTINCT destination
FROM flights;
SELECT *
FROM flights
ORDER BY departure_time ASC;
